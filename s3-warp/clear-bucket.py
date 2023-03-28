import os, sys, s3fs

if len(sys.argv) != 2:
    print("Must provide bucket name as only command line arg")
    exit(1)
BUCKET_NAME = sys.argv[1]
print("Removing bucket:", BUCKET_NAME)

fs = s3fs.S3FileSystem(
    key=os.getenv('WARP_ACCESS_KEY'),
    secret=os.getenv('WARP_SECRET_KEY'),
    client_kwargs = {"endpoint_url": "http://" + os.getenv('WARP_HOST')}
)

fs.rm(BUCKET_NAME, recursive=True)
