import torch       as torch
import torchvision as torchvision

import task.classifier.model as M



def load(input_path : str):

    # And, here a testing split. Why no validation?
    # FashionMNIST contains Tuple[Any, Any], where in our case,
    # Tuple[Tensor, ClassIndex]
    test_data = torchvision.datasets.FashionMNIST(
        root      = "/tmp/data"                      , # A folder path, inside of which the downloaded datasets will be stored.
        train     = False                            ,
        download  = True                             ,
        transform = torchvision.transforms.ToTensor(),
    )


    # Here, we pass Dataset -> DataLoader.
    test_dataloader  : torch.utils.data.DataLoader = torch.utils.data.DataLoader(test_data , batch_size=64, num_workers=0, shuffle=True)

    # A little preview of the data.
    # https://stackoverflow.com/questions/37689423/convert-between-nhwc-and-nchw-in-tensorflow
    print(f"N - number of images in a batch")
    print(f"C - number of channels of the image (ex: 3 for RGB, 1 for grayscale...)")
    print(f"H - height of the image")
    print(f"W - width of the image")
    for X, y in test_dataloader:
        print(f"Shape of X [N, C, H, W]: {X.shape}")
        print(f"Shape of y: {y.shape} {y.dtype}")
        break


    # Figuring out where we CAN run the model.
    device : str = "cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu"
    print(f"Using {device} device")


    # Loading models.
    model = M.NeuralNetwork().to(device)
    model.load_state_dict(torch.load(input_path))
    model.eval() # Set train flag to false.
    print(model)


    # The order is random but from this point on it must be followed by others.
    return (test_dataloader, device, model)


def _infer(device : str, dataloader : torch.utils.data.DataLoader, model : M.NeuralNetwork):

    # Performing demonstration.
    classes = [
        "T-shirt/top",
        "Trouser"    ,
        "Pullover"   ,
        "Dress"      ,
        "Coat"       ,
        "Sandal"     ,
        "Shirt"      ,
        "Sneaker"    ,
        "Bag"        ,
        "Ankle boot" ,
    ]

    with torch.no_grad():
        for X, y in dataloader:
            X, y = X.to(device), y.to(device) # Send data to the device?

            pred = model(X)
            
            for _, (p, a) in enumerate(zip(pred, y)):
                predicted, actual = classes[p.argmax(0)], classes[a]
                print(f"Predicted: '{predicted}', Actual '{actual}'")


# This function should be used as a way to interface with this part of the project.
def infer(input_path : str = "model.pth"):

    test_dataloader, device, model = load(input_path)
    _infer(device, test_dataloader, model)
    print("Done!")


# This function is to be triggered when running from CLI.
def main():
    infer("model.pth")


if __name__ == "__main__":
    main()