from typing import NamedTuple

class PrimitiveTriple(NamedTuple):
    a: int; b: int; c: int

def berggren_step(step: str, t: PrimitiveTriple) -> PrimitiveTriple:
    a, b, c = t
    if step == 'L':
        return PrimitiveTriple(a-2*b+2*c, 2*a-b+2*c, 2*a-2*b+3*c)
    elif step == 'M':
        return PrimitiveTriple(a+2*b+2*c, 2*a+b+2*c, 2*a+2*b+3*c)
    elif step == 'R':
        return PrimitiveTriple(-a+2*b+2*c, -2*a+b+2*c, -2*a+2*b+3*c)
    raise ValueError(f'Unknown step: {step}')

def berggren_word_eval(word: str, root: PrimitiveTriple = PrimitiveTriple(3,4,5)) -> PrimitiveTriple:
    t = root
    for step in word:
        t = berggren_step(step, t)
    return t

# Example: the word 'LMR' traverses left, then mid, then right
result = berggren_word_eval('LMR')
print(f'LMR -> {result}')  # A specific primitive Pythagorean triple
print(f'Check: {result.a}^2 + {result.b}^2 = {result.a**2 + result.b**2} = {result.c}^2 = {result.c**2}')