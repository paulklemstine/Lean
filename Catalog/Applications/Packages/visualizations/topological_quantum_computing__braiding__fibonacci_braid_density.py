#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import cmath

def main():
    phi = (1+np.sqrt(5))/2; phi_inv=1/phi
    F = np.array([[phi_inv, np.sqrt(phi_inv)],[np.sqrt(phi_inv), -phi_inv]])
    R = np.diag([cmath.exp(-4j*cmath.pi/5), cmath.exp(3j*cmath.pi/5)])
    sigma = F @ R @ np.linalg.inv(F)
    traces = []; U = np.eye(2, dtype=complex)
    np.random.seed(42)
    for _ in range(10000):
        U = U @ (sigma if np.random.random()<0.5 else np.linalg.inv(sigma))
        U /= np.sqrt(abs(np.linalg.det(U)))
        traces.append(np.real(np.trace(U)))
    plt.figure(figsize=(8,5))
    plt.hist(traces, bins=100, density=True, alpha=0.7, color='#3498db')
    t = np.linspace(-2,2,200)
    plt.plot(t, (1/np.pi)*np.sqrt(np.maximum(1-t**2/4,0)), 'r-', lw=2, label='Haar/Weyl')
    plt.xlabel('Re(tr(U))'); plt.ylabel('Density'); plt.title('Fibonacci Braid Trace Distribution'); plt.legend(); plt.grid(True,alpha=0.3)
    plt.savefig('braiding_density.png', dpi=150)

if __name__ == '__main__': main()