const config = require('./config.json')

const getVal = (env = '', key = '') => {
  return readConfig(`${env}.${key}`) || readConfig(`common.${key}`)
}

const readConfig = (key = '', obj = config) => {
  const currKey = key.split('.')[0]
  const val = obj[currKey]
  if (typeof val !== 'object') {
    return val
  }
  const nextKey = key.split('.').slice(1).join('.')
  return readConfig(nextKey, val)
}

const args = process.argv
const envIndex = args.findIndex((x) => x.trim() === 'env=') + 1
const keyIndex = args.findIndex((x) => x.trim() === 'key=') + 1
const env = args[envIndex].replaceAll(' ', '')
const key = args[keyIndex].replaceAll(' ', '')

const value = getVal(env, key)
console.log(value)
