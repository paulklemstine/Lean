from typing import Callable, Hashable, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
RVal = TypeVar("RVal", bound=Hashable)
SVal = TypeVar("SVal", bound=Hashable)

def fibrewise_equiv(enc_S: Callable[[bool], RVal], dec_S: Callable[[RVal], bool],
                    enc_T: Callable[[bool], SVal], dec_T: Callable[[SVal], bool]
                    ) -> Tuple[Callable[[RVal], SVal], Callable[[SVal], RVal]]:
    """Build the fibrewise equivalence R(a) ≃ R'(a) of two identity systems based
    at the same a0 by routing through the common path-family hub (a0 = a):
        R(a) --dec_S--> (a0=a) --enc_T--> R'(a)
    and the inverse symmetrically.  This realizes homotopy-initiality.
    """
    to_fun: Callable[[RVal], SVal] = lambda r: enc_T(dec_S(r))
    inv_fun: Callable[[SVal], RVal] = lambda s: enc_S(dec_T(s))
    return to_fun, inv_fun
