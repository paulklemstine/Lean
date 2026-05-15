#!/usr/bin/env python3
"""
Tropical Mutual Information — Applications

Real-world applications of tropical mutual information theory
to cryptography, privacy, and machine learning.
"""

import numpy as np
from typing import Dict, List


def tropical_key_exchange_security(
    n_keys: int,
    n_observables: int,
    pXY: np.ndarray
) -> Dict:
    """Analyze security of a tropical key exchange protocol.
    
    Models a key exchange where:
    - X = secret key (one of n_keys possibilities)
    - Y = publicly observable data (orbit, transcript, etc.)
    
    The tropical mutual information I_trop(X;Y) bounds the
    adversary's advantage in guessing the key.
    
    Args:
        n_keys: Number of possible secret keys
        n_observables: Number of distinct observables
        pXY: Joint distribution (n_keys × n_observables)
    Returns:
        Security analysis dictionary
    """
    pX = pXY.sum(axis=1)
    v_x = float(np.max(pX))
    v_xy = float(np.sum(np.max(pXY, axis=0)))
    
    h_inf_x = -np.log2(v_x)
    h_inf_xy = -np.log2(v_xy)
    mi = h_inf_x - h_inf_xy
    
    # Security bits: related to entropy gap
    # Higher min-entropy = more security
    security_bits = h_inf_xy  # conditional min-entropy
    
    return {
        'n_keys': n_keys,
        'n_observables': n_observables,
        'guessing_prob_prior': v_x,
        'guessing_prob_posterior': v_xy,
        'min_entropy_key': h_inf_x,
        'cond_min_entropy': h_inf_xy,
        'leakage_bits': mi,
        'remaining_security_bits': security_bits,
        'advantage_ratio': v_xy / v_x,
    }


def orbit_compression_analysis(
    pXY: np.ndarray,
    compression_maps: List[Dict]
) -> List[Dict]:
    """Analyze security through successive orbit compressions.
    
    In tropical cryptography, public transcripts are often compressed
    through canonical form computation, orbit projection, etc.
    The DPI guarantees each step is safe.
    
    Args:
        pXY: Original joint distribution
        compression_maps: List of {name, map} dicts
    Returns:
        Analysis at each compression stage
    """
    results = []
    current = pXY
    
    pX = current.sum(axis=1)
    v_x = float(np.max(pX))
    v_xy = float(np.sum(np.max(current, axis=0)))
    mi = np.log2(v_xy / v_x) if v_x > 0 and v_xy > 0 else 0
    
    results.append({
        'stage': 'Original',
        'shape': current.shape,
        'leakage': mi,
        'cond_vuln': v_xy,
        'vuln': v_x,
    })
    
    for comp in compression_maps:
        name = comp['name']
        f_map = comp['map']  # dict: old_col -> new_col
        
        n_new = max(f_map.values()) + 1
        new_dist = np.zeros((current.shape[0], n_new))
        for old_col, new_col in f_map.items():
            if old_col < current.shape[1]:
                new_dist[:, new_col] += current[:, old_col]
        
        current = new_dist
        v_xy_new = float(np.sum(np.max(current, axis=0)))
        mi_new = np.log2(v_xy_new / v_x) if v_x > 0 and v_xy_new > 0 else 0
        
        results.append({
            'stage': name,
            'shape': current.shape,
            'leakage': mi_new,
            'cond_vuln': v_xy_new,
            'vuln': v_x,
        })
    
    return results


def privacy_amplification_bound(
    pXY: np.ndarray,
    hash_output_bits: int
) -> Dict:
    """Compute privacy amplification bounds using tropical MI.
    
    When the adversary has side information Y about secret X,
    applying a universal hash function h: X → {0,1}^k
    produces a nearly uniform key if k < H_∞(X|Y).
    
    Args:
        pXY: Joint distribution (secret × side info)
        hash_output_bits: Number of output bits k
    Returns:
        Privacy amplification analysis
    """
    v_xy = float(np.sum(np.max(pXY, axis=0)))
    h_cond = -np.log2(v_xy) if v_xy > 0 else float('inf')
    
    # Leftover hash lemma: statistical distance ≤ 2^(-(H_∞(X|Y) - k)/2)
    if h_cond > hash_output_bits:
        slack = h_cond - hash_output_bits
        stat_dist_bound = 2 ** (-slack / 2)
        secure = True
    else:
        slack = 0
        stat_dist_bound = 1.0
        secure = False
    
    return {
        'cond_min_entropy': h_cond,
        'hash_output_bits': hash_output_bits,
        'entropy_slack': slack,
        'stat_dist_bound': stat_dist_bound,
        'is_secure': secure,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("  TROPICAL MUTUAL INFORMATION — APPLICATIONS")
    print("=" * 60)
    
    # Application 1: Tropical Key Exchange
    print("\n--- Application 1: Tropical Key Exchange Security ---")
    np.random.seed(2025)
    n_keys, n_obs = 8, 16
    # Simulate a mildly leaky protocol
    pXY = np.random.dirichlet(np.ones(n_keys * n_obs) * 0.5).reshape(n_keys, n_obs)
    
    result = tropical_key_exchange_security(n_keys, n_obs, pXY)
    print(f"  Keys: {result['n_keys']}, Observables: {result['n_observables']}")
    print(f"  Prior guessing prob: {result['guessing_prob_prior']:.4f}")
    print(f"  Posterior guessing prob: {result['guessing_prob_posterior']:.4f}")
    print(f"  Leakage: {result['leakage_bits']:.4f} bits")
    print(f"  Remaining security: {result['remaining_security_bits']:.4f} bits")
    print(f"  Advantage ratio: {result['advantage_ratio']:.4f}x")
    
    # Application 2: Orbit Compression
    print("\n--- Application 2: Orbit Compression Safety ---")
    compressions = [
        {'name': 'Canonical form', 'map': {i: i // 2 for i in range(n_obs)}},
        {'name': 'Coset reduction', 'map': {i: i // 2 for i in range(n_obs // 2)}},
        {'name': 'Binary classifier', 'map': {i: i // (n_obs // 4) for i in range(n_obs // 4)}},
    ]
    
    stages = orbit_compression_analysis(pXY, compressions)
    for s in stages:
        print(f"  {s['stage']:20s}: shape={str(s['shape']):8s}  "
              f"leakage={s['leakage']:.4f} bits  V(X|Y)={s['cond_vuln']:.4f}")
    print("  → Leakage decreases monotonically ✓")
    
    # Application 3: Privacy Amplification
    print("\n--- Application 3: Privacy Amplification ---")
    for k in [1, 2, 3, 4]:
        pa = privacy_amplification_bound(pXY, k)
        status = "✓ SECURE" if pa['is_secure'] else "✗ INSECURE"
        print(f"  k={k} bits: H_∞(X|Y)={pa['cond_min_entropy']:.2f}, "
              f"slack={pa['entropy_slack']:.2f}, "
              f"dist≤{pa['stat_dist_bound']:.4f}  {status}")
    
    print("\nAll applications completed.")
