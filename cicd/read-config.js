const commonConfig = require('./terraform/terraform.tfvars.json')

function getEnvConfig(env = '') {
  if (!env) {
    return {}
  }
  return require(`./terraform/environments/${env}.tfvars.json`)
}

const getVal = (env = '', key = '') => {
  const envConfig = getEnvConfig(env)
  const config = {
    common: commonConfig,
    [env]: envConfig,
  }
  return readConfig(`${env}.${key}`, config) || readConfig(`common.${key}`, config)
}

const readConfig = (key = '', obj) => {
  const currKey = key.split('.')[0]
  const val = obj[currKey]
  if (typeof val !== 'object') {
    return val
  }
  const nextKey = key.split('.').slice(1).join('.')
  return readConfig(nextKey, val)
}

const args = process.argv
const envIndex = args.findIndex((x) => x.trim().startsWith('env='))
const keyIndex = args.findIndex((x) => x.trim().startsWith('key='))
const env = args[envIndex].replaceAll('env=', '').trim()
const key = args[keyIndex].replaceAll('key=', '').trim()

const value = getVal(env, key)
console.log(value)
