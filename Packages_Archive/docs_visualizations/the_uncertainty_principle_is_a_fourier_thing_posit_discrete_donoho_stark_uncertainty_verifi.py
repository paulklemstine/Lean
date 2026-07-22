from __future__ import annotations
import numpy as np


def donoho_stark_verify(signal: np.ndarray, tol: float = 1e-9) -> dict[str, int | bool]:
    """Verify |supp f| * |supp Fhat| >= N for a length-N signal under the DFT.

    Returns the two support cardinalities, their product, N, and whether the bound holds.
    """
    n = signal.size
    fhat = np.fft.fft(signal)
    sf = int(np.sum(np.abs(signal) > tol))
    sh = int(np.sum(np.abs(fhat) > tol))
    return {"supp_f": sf, "supp_fhat": sh, "product": sf * sh,
            "N": n, "bound_holds": sf * sh >= n}
