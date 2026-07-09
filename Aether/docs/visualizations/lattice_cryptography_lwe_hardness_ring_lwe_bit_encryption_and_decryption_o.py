from dataclasses import dataclass
from typing import Tuple

@dataclass(frozen=True)
class Gaussian:
    re: int
    im: int
    def __add__(self, o: "Gaussian") -> "Gaussian":
        return Gaussian(self.re + o.re, self.im + o.im)
    def __sub__(self, o: "Gaussian") -> "Gaussian":
        return Gaussian(self.re - o.re, self.im - o.im)
    def __mul__(self, o: "Gaussian") -> "Gaussian":
        return Gaussian(self.re * o.re - self.im * o.im,
                        self.re * o.im + self.im * o.re)

def decode_coord(t: int, v: int) -> int:
    return 0 if 2 * v < t else 1

def encrypt(t: int, s: Gaussian, a: Gaussian, e_re: int, e_im: int,
            m_re: int, m_im: int) -> Tuple[Gaussian, Gaussian]:
    v = a * s + Gaussian(e_re, e_im) + Gaussian(m_re * t, m_im * t)
    return (a, v)

def decrypt(t: int, s: Gaussian, c: Tuple[Gaussian, Gaussian]) -> Tuple[int, int]:
    u, v = c
    phase = v - u * s
    return (decode_coord(t, phase.re), decode_coord(t, phase.im))
