import numpy as np
def hopf_preimage(x, y, z, n=200):
    r1 = np.sqrt(max((1+z)/2,0)); r2 = np.sqrt(max((1-z)/2,0))
    phi = np.arctan2(y,x) if r1*r2>1e-10 else 0
    thetas = np.linspace(0,2*np.pi,n,endpoint=False)
    return [(r1*np.exp(1j*t), r2*np.exp(1j*(t-phi))) for t in thetas]