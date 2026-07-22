import math
import numpy as np

def mellin_vertical_line(fx: np.ndarray, u: np.ndarray, sigma: float) -> tuple[np.ndarray, np.ndarray]:
    """Compute a sampled Mellin vertical line from a uniform log grid."""
    if fx.shape != u.shape or u.size < 2:
        raise ValueError("fx and u must be matching sampled arrays")
    du = float(u[1]-u[0])
    g = fx * np.exp(sigma*u)
    values = np.fft.fftshift(np.fft.ifft(np.fft.ifftshift(g))) * (u.size*du)
    omega = 2.0*math.pi*np.fft.fftshift(np.fft.fftfreq(u.size, d=du))
    return omega, values
