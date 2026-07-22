from enum import Enum
class Arrow(str, Enum): E="e"; A="a"; B="b"
def compose(x: Arrow, y: Arrow) -> Arrow:
    table={(Arrow.E,Arrow.E):Arrow.E,(Arrow.E,Arrow.A):Arrow.A,(Arrow.E,Arrow.B):Arrow.B,(Arrow.A,Arrow.E):Arrow.A,(Arrow.A,Arrow.A):Arrow.B,(Arrow.A,Arrow.B):Arrow.A,(Arrow.B,Arrow.E):Arrow.B,(Arrow.B,Arrow.A):Arrow.E,(Arrow.B,Arrow.B):Arrow.B}
    return table[x,y]
a=Arrow.A
print("(a∘a)∘a =", compose(compose(a,a),a).value)
print("a∘(a∘a) =", compose(a,compose(a,a)).value)
