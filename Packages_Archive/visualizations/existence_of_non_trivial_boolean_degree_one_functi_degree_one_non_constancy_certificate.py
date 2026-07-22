from typing import Tuple

def nonconstant_certificate(q: int, x: int) -> Tuple[bool, bool, bool]:
    """Certify non-constancy of any Cameron-Liebler class at parameter x.

    By the degree-one counting identity the support size of a class with
    parameter x is forced to be x*(q^2+q+1). Hence the class:
      * takes value True somewhere  iff  support_size > 0   (i.e. x > 0)
      * takes value False somewhere iff  support_size < N   (i.e. x < q^2+1)
    where N = (q^2+1)(q^2+q+1) is the total number of lines.

    Returns (has_true, has_false, is_non_constant).
    """
    nltp: int = q * q + q + 1
    total: int = (q * q + 1) * nltp
    support_size: int = x * nltp
    has_true: bool = support_size > 0
    has_false: bool = support_size < total
    return has_true, has_false, (has_true and has_false)
