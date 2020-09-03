#### 디렉토리 구성
<pre>
 ┬  
 ├ .docker
     ┬ 
     ├ nginx
     ├ Dockerfile
     ├ Dockerfile.nginx
     ├ generate-dockerrun.sh
     ├ generate-version.sh
     
 ├ Jenkinsfile    
 ├ app.js
</pre>

기존 App 을 위한 파일 외에 .docker, Jenkinsfile 존재.

##### generate-dockerrun.sh
- generate-dockerrun.sh => ECR_REGISTRY_URL 변경 필요
- Jenkinsfile => 변수 변경 필요

#### Issue, Access Denied Error, GetAuthorizationToken 
- IAM role - aws-elasticbeanstalk-ec2-role 변경
```shell script
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        }
    ]
}
```