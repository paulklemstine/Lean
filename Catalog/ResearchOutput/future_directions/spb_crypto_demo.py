"""
SPB Quantum Cryptography Demo
===============================
Future Direction 6.3: SPB-based key exchange protocol.

The SPB operation s ⊕ t = (s+t)/(1-st) (tangent addition) forms
a group structure that enables Diffie-Hellman-like key exchange.

This demo shows:
  1. SPB group properties verification
  2. Iterated SPB and the discrete log analog
  3. Key exchange protocol simulation
  4. One-way function properties of multi-SPB composition
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def spb(s, t):
    """SPB operation: tangent addition formula."""
    denom = 1 - s * t
    if abs(denom) < 1e-15:
        return float('inf')
    return (s + t) / denom


def iterated_spb(g, n):
    """Apply SPB n times: g ⊕ g ⊕ ... ⊕ g (n times)."""
    result = 0.0
    for _ in range(n):
        result = spb(result, g)
    return result


def multi_spb(values):
    """Compose a list of values via SPB."""
    result = 0.0
    for v in values:
        result = spb(result, v)
    return result


# ============================================================
# Demo 1: SPB Group Properties
# ============================================================
def demo_group_properties():
    """Verify and visualize SPB group structure."""
    # Test commutativity, identity, inverses
    test_values = np.linspace(-2, 2, 50)

    comm_errors = []
    identity_errors = []
    inverse_errors = []

    for s in test_values:
        for t in test_values:
            if abs(1 - s * t) > 1e-10:
                comm_errors.append(abs(spb(s, t) - spb(t, s)))
        identity_errors.append(abs(spb(s, 0) - s))
        inverse_errors.append(abs(spb(s, -s)))

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Commutativity
    axes[0, 0].hist(comm_errors, bins=50, color='steelblue', edgecolor='black')
    axes[0, 0].set_xlabel('|s⊕t - t⊕s|', fontsize=12)
    axes[0, 0].set_ylabel('Count', fontsize=12)
    axes[0, 0].set_title(f'Commutativity: max error = {max(comm_errors):.2e}', fontsize=13)
    axes[0, 0].grid(True, alpha=0.3)

    # SPB surface plot
    S, T = np.meshgrid(np.linspace(-1.5, 1.5, 100), np.linspace(-1.5, 1.5, 100))
    Z = np.zeros_like(S)
    for i in range(S.shape[0]):
        for j in range(S.shape[1]):
            denom = 1 - S[i, j] * T[i, j]
            if abs(denom) > 0.01:
                Z[i, j] = (S[i, j] + T[i, j]) / denom
            else:
                Z[i, j] = np.nan

    im = axes[0, 1].contourf(S, T, np.clip(Z, -5, 5), levels=30, cmap='RdBu_r')
    plt.colorbar(im, ax=axes[0, 1])
    axes[0, 1].set_xlabel('s', fontsize=12)
    axes[0, 1].set_ylabel('t', fontsize=12)
    axes[0, 1].set_title('SPB(s,t) Surface', fontsize=13)

    # Iterated SPB
    g_values = [0.1, 0.3, 0.5, 0.7]
    for g in g_values:
        ns = range(1, 20)
        vals = [iterated_spb(g, n) for n in ns]
        tan_vals = [np.tan(n * np.arctan(g)) for n in ns]
        axes[1, 0].plot(ns, vals, 'o-', markersize=4, label=f'g={g}')

    axes[1, 0].set_xlabel('n (iterations)', fontsize=12)
    axes[1, 0].set_ylabel('Iterated SPB value', fontsize=12)
    axes[1, 0].set_title('Iterated SPB: g⊕g⊕...⊕g', fontsize=13)
    axes[1, 0].legend(fontsize=10)
    axes[1, 0].grid(True, alpha=0.3)

    # Comparison with tan(n·arctan(g))
    g = 0.3
    ns = range(1, 15)
    spb_vals = [iterated_spb(g, n) for n in ns]
    tan_vals = [np.tan(n * np.arctan(g)) for n in ns]
    errors = [abs(s - t) for s, t in zip(spb_vals, tan_vals)]

    axes[1, 1].semilogy(list(ns), errors, 'ro-', markersize=5)
    axes[1, 1].set_xlabel('n', fontsize=12)
    axes[1, 1].set_ylabel('|SPB^n(g) - tan(n·arctan(g))|', fontsize=12)
    axes[1, 1].set_title(f'SPB vs tan Formula (g={g})', fontsize=13)
    axes[1, 1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spb_crypto_group.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1: SPB group properties saved")
    print(f"  Max commutativity error: {max(comm_errors):.2e}")
    print(f"  Max identity error: {max(identity_errors):.2e}")
    print(f"  Max inverse error: {max(inverse_errors):.2e}")


# ============================================================
# Demo 2: Key Exchange Protocol
# ============================================================
def demo_key_exchange():
    """
    Simulate the SPB Diffie-Hellman key exchange.
    Alice: picks a, computes A = SPB^a(g)
    Bob: picks b, computes B = SPB^b(g)
    Shared key: Alice computes SPB^a(B), Bob computes SPB^b(A)
    """
    np.random.seed(42)

    g = 0.2  # Public generator
    n_trials = 100

    alice_secrets = np.random.randint(1, 50, n_trials)
    bob_secrets = np.random.randint(1, 50, n_trials)

    agreement_errors = []

    for a, b in zip(alice_secrets, bob_secrets):
        # Public keys
        A = iterated_spb(g, a)
        B = iterated_spb(g, b)

        # Shared secrets
        alice_key = iterated_spb(B, a)
        bob_key = iterated_spb(A, b)

        agreement_errors.append(abs(alice_key - bob_key))

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Key agreement histogram
    axes[0].hist(agreement_errors, bins=50, color='green', edgecolor='black', alpha=0.7)
    axes[0].set_xlabel('|Alice Key - Bob Key|', fontsize=12)
    axes[0].set_ylabel('Count', fontsize=12)
    axes[0].set_title(f'Key Agreement Error (n={n_trials} trials)', fontsize=13)
    axes[0].grid(True, alpha=0.3)

    # Public key distribution
    public_keys_alice = [iterated_spb(g, a) for a in range(1, 100)]
    axes[1].plot(range(1, 100), public_keys_alice, 'b.-', markersize=3)
    axes[1].set_xlabel('Secret key a', fontsize=12)
    axes[1].set_ylabel('Public key A = SPB^a(g)', fontsize=12)
    axes[1].set_title(f'Public Key vs Secret (g={g})', fontsize=13)
    axes[1].grid(True, alpha=0.3)

    # Phase space visualization
    theta = np.array([n * np.arctan(g) for n in range(1, 200)])
    theta_mod = theta % np.pi  # Wrap to [0, π)
    axes[2].scatter(range(1, 200), theta_mod, c=range(1, 200),
                     cmap='viridis', s=10, alpha=0.7)
    axes[2].set_xlabel('Secret key n', fontsize=12)
    axes[2].set_ylabel('Phase angle (mod π)', fontsize=12)
    axes[2].set_title('Phase Space Orbit', fontsize=13)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spb_crypto_exchange.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\n✓ Demo 2: Key exchange protocol saved")
    print(f"  Mean agreement error: {np.mean(agreement_errors):.2e}")
    print(f"  Max agreement error: {np.max(agreement_errors):.2e}")
    print(f"  Perfect agreement: {sum(e < 1e-10 for e in agreement_errors)}/{n_trials}")


# ============================================================
# Demo 3: One-Way Function Analysis
# ============================================================
def demo_one_way():
    """
    Analyze the difficulty of inverting the iterated SPB function.
    """
    g = 0.2

    # Forward computation: easy
    ns = range(1, 200)
    forward_vals = [iterated_spb(g, n) for n in ns]

    # Sensitivity analysis: small change in n → how much change in output?
    sensitivities = []
    for n in range(2, 199):
        val_n = iterated_spb(g, n)
        val_n1 = iterated_spb(g, n + 1)
        sensitivities.append(abs(val_n1 - val_n))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].plot(list(ns), forward_vals, 'b-', linewidth=1)
    axes[0].set_xlabel('n (secret key)', fontsize=12)
    axes[0].set_ylabel('SPB^n(g)', fontsize=12)
    axes[0].set_title(f'Forward Function (g={g})', fontsize=13)
    axes[0].grid(True, alpha=0.3)

    axes[1].semilogy(range(2, 199), sensitivities, 'r-', linewidth=1)
    axes[1].set_xlabel('n', fontsize=12)
    axes[1].set_ylabel('|SPB^{n+1}(g) - SPB^n(g)|', fontsize=12)
    axes[1].set_title('Sensitivity: Adjacent Key Difference', fontsize=13)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spb_crypto_oneway.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\n✓ Demo 3: One-way function analysis saved")
    print(f"  Mean sensitivity: {np.mean(sensitivities):.6f}")


if __name__ == '__main__':
    print("=" * 60)
    print("SPB Quantum Cryptography — Future Direction 6.3")
    print("=" * 60)

    demo_group_properties()
    demo_key_exchange()
    demo_one_way()

    print("\n" + "=" * 60)
    print("All demos complete! Generated 3 PNG files.")
    print("=" * 60)
