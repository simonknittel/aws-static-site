const { CloudFrontClient, CreateInvalidationCommand, ListDistributionsCommand } = require('@aws-sdk/client-cloudfront')

const cfClient = new CloudFrontClient({ region: 'eu-central-1' })

exports.handler = async function handler(event, context) {
  const bucket = event.Records[0].s3.bucket.name

  let file_key = event.Records[0].s3.object.key
  if (file_key.indexOf('/') !== 0) file_key = '/' + file_key

  const ciCommand = new CreateInvalidationCommand({
    DistributionId: await getDistributionId(bucket),
    InvalidationBatch: {
      CallerReference: Date.now(),
      Paths: {
        Quantity: 1,
        Items: [ file_key ]
      }
    }
  })

  try {
    return await cfClient.send(ciCommand)
  } catch (error) {
    throw error
  }
}

async function getDistributionId(bucket) {
  let allDistributions = []

  try {
    allDistributions = await cfClient.send(new ListDistributionsCommand({}))
  } catch (error) {
    throw error
  }

  for (let i = 0; i < allDistributions.DistributionList.Items.length; i++) {
    const distribution = allDistributions.DistributionList.Items[i]

    for (let j = 0; j < distribution.Origins.Items.length; j++) {
      const origin = distribution.Origins.Items[j]
      const bucketNameOfOrigin = origin.DomainName.replace('.s3.eu-central-1.amazonaws.com', '')

      if (bucketNameOfOrigin !== bucket) continue
      return distribution.Id
    }
  }
}
