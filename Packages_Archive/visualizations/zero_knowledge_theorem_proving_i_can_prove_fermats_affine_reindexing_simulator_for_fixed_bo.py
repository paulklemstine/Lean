from typing import Callable, TypeVar
G=TypeVar("G"); H=TypeVar("H")
def simulate(response: G, challenge: int, hom: Callable[[G],H], sub: Callable[[H,H],H], target: H, zero: H) -> tuple[H,int,G]:
    if challenge not in (0,1): raise ValueError("Boolean challenge required")
    return (hom(response) if challenge==0 else sub(hom(response),target), challenge, response)
