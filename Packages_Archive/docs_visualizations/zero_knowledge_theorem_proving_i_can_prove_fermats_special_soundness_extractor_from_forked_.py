from typing import Callable, TypeVar
G=TypeVar("G"); H=TypeVar("H")
def extract(a: H,z0: G,z1: G,hom: Callable[[G],H],sub_g: Callable[[G,G],G],add_h: Callable[[H,H],H],target: H) -> G:
    if hom(z0)!=a or hom(z1)!=add_h(a,target): raise ValueError("nonaccepting pair")
    w=sub_g(z1,z0)
    if hom(w)!=target: raise AssertionError("extraction invariant")
    return w
