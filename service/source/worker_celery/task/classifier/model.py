import torch       as torch
import torchvision as torchvision


# Creating the model.
class NeuralNetwork(torch.nn.Module):

    # For successfull, operation, this function is a MUST.
    def __init__(self):

        super().__init__()
        self.flatten = torch.nn.Flatten()
        self.linear_relu_stack = torch.nn.Sequential(
            torch.nn.Linear(28 * 28, 512),
            torch.nn.ReLU()              ,
            torch.nn.Linear(512, 512)    ,
            torch.nn.ReLU()              ,
            torch.nn.Linear(512, 10)     ,
        )

    # For successfull, operation, this function is a MUST.
    def forward(self, x):

        x      = self.flatten(x)
        logits = self.linear_relu_stack(x)
        return logits
