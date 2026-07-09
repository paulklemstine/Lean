from dataclasses import dataclass

@dataclass(frozen=True)
class BLS:
    n: int   # order of source group G = Z_n
    p: int   # prime defining target field (Z_p)^*
    gt: int  # generator of order-n target subgroup
    g: int = 1

    def smul(self, x: int, point: int) -> int:
        return (x * point) % self.n

    def e(self, a: int, b: int) -> int:
        return pow(self.gt, (a * b) % self.n, self.p)

    def keygen(self, x: int) -> int:
        return self.smul(x, self.g)            # public key X = x.g

    def sign(self, x: int, h: int) -> int:
        return self.smul(x, h)                 # sigma = x.H

    def verify(self, pub: int, h: int, sig: int) -> bool:
        return self.e(sig, self.g) == self.e(h, pub)
