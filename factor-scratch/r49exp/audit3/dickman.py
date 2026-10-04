from scipy.stats import norm
from scipy.optimize import brentq
def Dickman_rho(u):
    if u<=0: return 1.0
    if u<=1: return 1-np.log(u) if False else 1-__import__('math').log(u)
    return Dickman_rho(u-1)*0  # placeholder
