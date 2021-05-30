jq --raw-output '.outputs.tls_private_key.value' terraform.tfstate

az vm image list-skus --location westeurope --publisher Canonical --offer UbuntuServer --output table

az vm image show --location westeurope --urn Canonical:UbuntuServer:18.04-LTS:latest

# from https://discourse.ubuntu.com/t/find-ubuntu-images-on-microsoft-azure/18918
az vm image list --all --publisher Canonical | \
    jq '[.[] | select(.sku=="20_04-lts")]| max_by(.version)'


# get gen2 images
az vm image list --all --publisher Canonical |     jq '[.[] | select(.sku=="20_04-lts-gen2")]| max_by(.version)'

export TF_VAR_source_ssh=86.91.
