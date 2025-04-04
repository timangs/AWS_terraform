docker build -t lambda-layer-builder .
docker create --name temp-layer-container lambda-layer-builder
mkdir ./python_layer_output
docker cp temp-layer-container:/layer-build/python ./python_layer_output/python
docker rm temp-layer-container
cd python_layer_output

zip -r ../lambda_layer_docker.zip python/ # Linux
Compress-Archive -Path python -DestinationPath ../lambda_layer_docker.zip # Windows