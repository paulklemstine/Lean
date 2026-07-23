from __future__ import annotations
import numpy as np


def support_measure_certifier(widths: list[float], threshold: float = 0.05,
                              kmax: float = 200.0, samples: int = 400001
                              ) -> list[tuple[float, float]]:
    """For each box width w, return (w, effective support measure of its sinc transform).

    The transform of the indicator of [-w/2, w/2] is w*sinc(w*k) = sin(pi w k)/(pi k).
    The effective support is the Lebesgue measure of {k : |transform(k)| > threshold*peak}.
    """
    k = np.linspace(-kmax, kmax, samples)
    out: list[tuple[float, float]] = []
    for w in widths:
        with np.errstate(divide="ignore", invalid="ignore"):
            trans = np.where(k == 0, w, np.sin(np.pi * w * k) / (np.pi * k))
        peak = float(np.abs(trans).max())
        meas = float(np.sum(np.abs(trans) > threshold * peak) * (k[1] - k[0]))
        out.append((w, meas))
    return out
