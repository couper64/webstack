from dummy import add, hello # type: ignore

def test_add():
    assert add(2, 3) == 5

def test_hello():
    assert hello() == "Hello from my package!"