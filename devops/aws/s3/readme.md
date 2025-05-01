# Create Amazon S3 Cross Region Replication with Terraform

## How to Test CRR Setup
- Create an object in the source bucket and see if it gets replicated in the destination bucket.
```shell
# Put a file in the source bucket
aws s3 cp test-file.txt s3://my-source-bucket-example/

# Check if file is there in the destination bucket
aws s3 ls s3://my-destination-bucket-example/
```

## Advantages of Cross-Region Replication
1. Disaster recovery. Protect data by mirroring it across different geographical regions. 
2. Compliance. Meet regulatory requirements for data location and backup. 
3. Improved performance. Reduce latency by storing data closer to users. 
4. Backup automation. Manage backups and archives without additional tools or scripts.

## Troubleshooting Tips
1. Permission errors. Verify the IAM role has correct permissions on source and destination buckets. 
2. Versioning not enabled. Make sure versioning is enabled on both source and destination buckets. 
3. Replication delays. Replication is eventually consistent. Monitor replication using CloudWatch.

## Conclusion
- [Amazon S3](https://dzone.com/articles/master-the-art-of-querying-data-on-amazon-s3) Cross-Region Replication is a very powerful feature for any business to achieve appropriate data redundancy and compliance. Terraform enables you to automate and streamline the implementation process so the infrastructure setup remains consistent and scalable. 
- In this tutorial, we have learned how to implement CRR using Terraform, from bucket configuration to replication rule definitions. Based on the method described in this article, you can design your optimal storage architecture to handle the needs of a modern enterprise application.
