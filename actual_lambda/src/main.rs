use std::env;

use aws_config::load_from_env;
use aws_lambda_events::event::s3::S3Event;
use aws_sdk_s3::Client;
use lambda_runtime::{run, service_fn, Error, LambdaEvent};

/// This is the main body for the function.
/// Write your code inside it.
/// There are some code example in the following URLs:
/// - https://github.com/awslabs/aws-lambda-rust-runtime/tree/main/examples
/// - https://github.com/aws-samples/serverless-rust-demo/
async fn function_handler(event: LambdaEvent<S3Event>) -> Result<(), Error> {
    let LambdaEvent { payload, .. } = event;
    for record in payload.records {
        let bucket = record.s3.bucket.name.unwrap();
        let key = record.s3.object.key.unwrap();

        let config = load_from_env().await;
        let client = Client::new(&config);

        let output_bucket_name = env::var("AWS_OUTPUT_BUCKET_NAME")
            .expect("failed to get output bucket name from env var");
        let object = client.get_object().bucket(&bucket).key(&key).send().await?;
        client
            .put_object()
            .bucket(&output_bucket_name)
            .key(&key)
            .body(object.body)
            .send()
            .await?;
        client
            .delete_object()
            .bucket(&bucket)
            .key(&key)
            .send()
            .await?;
    }

    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        // disable printing the name of the module in every log line.
        .with_target(false)
        // disabling time is handy because CloudWatch will add the ingestion time.
        .without_time()
        .init();

    run(service_fn(function_handler)).await
}
