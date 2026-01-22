import { initialState } from '../initial_state';

export function isDevelopment() {
  if (typeof process !== 'undefined')
    return process.env.NODE_ENV === 'development';
  else return import.meta.env.DEV;
}

export function isProduction() {
  if (typeof process !== 'undefined')
    return process.env.NODE_ENV === 'production';
  else return import.meta.env.PROD;
}

export function isRailsProduction() {
  return process.env.RAILS_ENV === 'production';
}

export type Features =
  | 'modern_emojis'
  | 'outgoing_quotes'
  | 'fasp'
  | 'http_message_signatures';

export type ServerFeatures = 'fasp';

export function isServerFeatureEnabled(feature: ServerFeatures) {
  return initialState?.features.includes(feature) ?? false;
}

type ClientFeatures = 'profile_redesign';

export function isClientFeatureEnabled(feature: ClientFeatures) {
  try {
    const features =
      window.localStorage.getItem('experiments')?.split(',') ?? [];
    return features.includes(feature);
  } catch (err) {
    console.warn('Could not access localStorage to get client features', err);
    return false;
  }
}
