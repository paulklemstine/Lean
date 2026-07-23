import math
import numpy as np

def fourier_energy_widths(samples: np.ndarray, spacing: float) -> tuple[float, float]:
    """Estimate position and angular-frequency energy standard deviations."""
    n = samples.size
    x = (np.arange(n) - n//2) * spacing
    spectrum = np.fft.fftshift(np.fft.fft(np.fft.ifftshift(samples))) * spacing
    k = 2.0 * math.pi * np.fft.fftshift(np.fft.fftfreq(n, d=spacing))
    def std(axis: np.ndarray, values: np.ndarray, step: float) -> float:
        weights = np.abs(values)**2 * step
        weights /= weights.sum()
        center = float(np.sum(axis * weights))
        return float(np.sqrt(np.sum((axis-center)**2 * weights)))
    return std(x, samples, spacing), std(k, spectrum, float(k[1]-k[0]))
