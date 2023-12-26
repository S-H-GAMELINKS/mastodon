# frozen_string_literal: true

class SearchService < BaseService
  QUOTE_EQUIVALENT_CHARACTERS = /[“”„«»「」『』《》]/

  def call(query, account, limit, options = {})
    @query         = query&.strip&.gsub(QUOTE_EQUIVALENT_CHARACTERS, '"')
    @account       = account
    @options       = options
    @limit         = limit.to_i
    @offset        = options[:type].blank? ? 0 : options[:offset].to_i
    @resolve       = options[:resolve] || false
    @following     = options[:following] || false
    @profile       = options[:with_profiles] || false
    @searchability = options[:searchability] || @account&.user&.setting_default_search_searchability || 'private'

    default_results.tap do |results|
      next if @query.blank? || @limit.zero?

      if url_query?
        results.merge!(url_resource_results) unless url_resource.nil? || @offset.positive? || (@options[:type].present? && url_resource_symbol != @options[:type].to_sym)
      elsif @query.present?
        results[:accounts] = perform_accounts_search! if account_searchable?
        results[:statuses] = perform_statuses_search! if status_searchable?
        results[:hashtags] = perform_hashtags_search! if hashtag_searchable?

        if @profile
          results[:profiles] = perform_accounts_full_text_search! if profile_searchable?
        elsif profile_searchable?
          accounts_count = results[:accounts].count

          if accounts_count == 0
            # @offset -= count_accounts_search!
            results[:accounts] = perform_accounts_full_text_search!
          elsif accounts_count < @limit
            @limit -= accounts_count
            @offset = 0
            results[:accounts] = results[:accounts].concat(perform_accounts_full_text_search!)
          end
        end
      end
    end
  end

  private

  def perform_accounts_search!
    AccountSearchService.new.call(
      @query,
      @account,
      limit: @limit,
      resolve: @resolve,
      offset: @offset,
      language: @options[:language],
      use_searchable_text: true,
      following: @following,
      start_with_hashtag: @query.start_with?('#')
    )
  end

  def count_accounts_search!
    AccountSearchService.new.count(
      @query,
      @account,
      language: @options[:language]
    )
  end

  def perform_accounts_full_text_search!
    AccountFullTextSearchService.new.call(
      @query,
      @account,
      limit: @limit,
      resolve: @resolve,
      offset: @offset,
      language: @options[:language]
    )
  end

  def perform_statuses_search!
    StatusesSearchService.new.call(
      @query,
      @account,
      limit: @limit,
      offset: @offset,
      account_id: @options[:account_id],
      searchability: @options[:searchability],
      min_id: @options[:min_id],
      max_id: @options[:max_id]
    )
  end

  def perform_hashtags_search!
    TagSearchService.new.call(
      @query,
      limit: @limit,
      offset: @offset,
      exclude_unreviewed: @options[:exclude_unreviewed],
      language: @options[:language]
    )
  end

  def default_results
    { accounts: [], hashtags: [], statuses: [], profiles: [], custom_emojis: [] }
  end

  def url_query?
    @resolve && /\Ahttps?:\/\//.match?(@query)
  end

  def url_resource_results
    { url_resource_symbol => [url_resource] }
  end

  def url_resource
    @_url_resource ||= ResolveURLService.new.call(@query, on_behalf_of: @account)
  end

  def url_resource_symbol
    url_resource.class.name.underscore.pluralize.to_sym.then { |symbol| if symbol == :tags then :hashtags else symbol end }
  end

  def status_searchable?
    Chewy.enabled? && status_search? && @account.present?
  end

  def account_searchable?
    !@profile && account_search? || profiles_search?
  end

  def profile_searchable?
    Chewy.enabled? && @account.present? && !@profile && account_search? || profiles_search?
  end

  def hashtag_searchable?
    hashtag_search?
  end

  def account_search?
    @options[:type].blank? || @options[:type] == 'accounts'
  end

  def hashtag_search?
    @options[:type].blank? || @options[:type] == 'hashtags'
  end

  def status_search?
    @options[:type].blank? || @options[:type] == 'statuses'
  end

  def profiles_search?
    @options[:type].blank? || @options[:type] == 'profiles'
  end
end
