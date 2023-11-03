export function isDevelopment() {
  return process.env.NODE_ENV === 'development';
}

export function isProduction() {
  return process.env.NODE_ENV === 'production';
}

export function isRailsProduction() {
  return process.env.RAILS_ENV === 'production';
}
