def stub(url, method = :get, with = {}, &block)
  body = yield
  WebMock.stub_request(method, %r[#{url}]).with(with).to_return body: body
end

stub %r[(.*)/meta-data/iam/security-credentials] do
<<-BODY
  {
    "Code" : "Success",
    "LastUpdated" : "2012-04-26T16:39:16Z",
    "Type" : "AWS-HMAC",
    "AccessKeyId" : "FAKE_ACCESS_KEY_ID",
    "SecretAccessKey" : "FAKE_SECRET_ACCESS_KEY",
    "Token" : "token",
    "Expiration" : "2012-04-27T22:39:16Z"
  }
BODY
end

stub %r[ec2.us-east-1.amazonaws.com], :post, body: /DescribeImages&Owner.1=self/ do
<<-BODY
{
    "ImageId": "ami-5731123e"
}
BODY
end