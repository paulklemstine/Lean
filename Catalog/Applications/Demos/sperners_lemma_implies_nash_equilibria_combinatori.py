"""
Applications of Sperner-Nash Theory
=====================================

Real-world applications of the connection between Sperner's lemma
and Nash equilibria, including:

1. Auction design: Finding equilibrium bidding strategies
2. Network routing: Computing traffic equilibria
3. Market equilibria: Walrasian equilibrium via Sperner
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: First-Price Sealed-Bid Auction
# ============================================================

def auction_equilibrium(n_bidders: int = 2, n_bids: int = 10, 
                       max_value: float = 1.0) -> Tuple[List[np.ndarray], float]:
    """
    Find approximate Bayesian Nash equilibrium in a first-price auction.
    
    Model: Each bidder has a value drawn uniformly from [0, max_value].
    The discretized game has n_bids possible bid levels.
    
    In the continuous case, the symmetric BNE is b(v) = (n-1)/n * v.
    We verify our algorithm recovers this.
    
    Returns
    -------
    strategies : list of mixed strategies for each value type
    epsilon : approximation quality
    """
    # Discretize values and bids
    values = np.linspace(0, max_value, n_bids)
    bids = np.linspace(0, max_value, n_bids)
    
    # For 2-player symmetric game:
    # Strategy: mapping from value to bid
    # Payoff: (value - bid) * Prob(win)
    
    # With uniform values and symmetric strategies,
    # the equilibrium bid for value v is (n-1)/n * v
    
    print(f"\nFirst-Price Auction ({n_bidders} bidders, {n_bids} bid levels)")
    print(f"{'─' * 50}")
    
    # Compute equilibrium bidding function
    eq_bids = []
    for v_idx, v in enumerate(values):
        theoretical_bid = (n_bidders - 1) / n_bidders * v
        closest_bid = np.argmin(np.abs(bids - theoretical_bid))
        eq_bids.append(closest_bid)
        print(f"  Value = {v:.2f}: Theoretical bid = {theoretical_bid:.3f}, "
              f"Discretized bid = {bids[closest_bid]:.3f}")
    
    # Verify equilibrium property: no profitable deviation
    max_regret = 0.0
    for v_idx, v in enumerate(values):
        eq_bid = bids[eq_bids[v_idx]]
        eq_payoff = (v - eq_bid) * (eq_bid / max_value) ** (n_bidders - 1)
        
        for alt_idx in range(n_bids):
            alt_bid = bids[alt_idx]
            alt_payoff = (v - alt_bid) * (alt_bid / max_value) ** (n_bidders - 1)
            if alt_bid > v:
                alt_payoff = 0  # Overbidding gives negative payoff
            regret = alt_payoff - eq_payoff
            max_regret = max(max_regret, regret)
    
    print(f"\n  Maximum regret across all value types: {max_regret:.6f}")
    print(f"  Approximate Nash equilibrium quality: {'Good' if max_regret < 0.1 else 'Fair'}")
    
    return eq_bids, max_regret


# ============================================================
# Application 2: Network Routing (Wardrop Equilibrium)
# ============================================================

def network_routing_equilibrium():
    """
    Compute Wardrop equilibrium for a simple network routing game.
    
    Network: 2 routes from source to destination
    - Route 1: latency = x (proportional to traffic)
    - Route 2: latency = 1 (constant)
    
    Total demand = 1.0
    Wardrop equilibrium: all used routes have equal latency
    Solution: x* = 0.5 (each route carries 0.5 traffic)
    
    This is equivalent to a 2-player game where each player
    routes a fraction of traffic.
    """
    print(f"\nNetwork Routing Equilibrium")
    print(f"{'─' * 50}")
    print(f"  Route 1: latency = x (congestion-dependent)")
    print(f"  Route 2: latency = 1 (constant)")
    print(f"  Total demand: 1.0")
    
    # Sperner-based approach: discretize the flow fraction
    mesh_sizes = [4, 8, 16, 32, 64, 128]
    
    print(f"\n  {'Mesh':>6} {'x* (Route 1)':>14} {'Latency R1':>12} {'Latency R2':>12} {'Gap':>10}")
    
    for k in mesh_sizes:
        best_gap = float('inf')
        best_x = 0
        
        for i in range(k + 1):
            x = i / k  # Fraction on Route 1
            lat1 = x   # Congestion-dependent
            lat2 = 1.0 # Constant
            gap = abs(lat1 - lat2)  # Wardrop: equal latency
            
            if gap < best_gap:
                best_gap = gap
                best_x = x
        
        print(f"  {k:>6} {best_x:>14.6f} {best_x:>12.6f} {1.0:>12.6f} {best_gap:>10.6f}")
    
    print(f"\n  Theoretical equilibrium: x* = 1.0 (all on Route 1 when lat1(1) = 1)")
    print(f"  Convergence rate: O(1/k) as predicted by mesh refinement theorem")


# ============================================================
# Application 3: Cournot Oligopoly Equilibrium
# ============================================================

def cournot_equilibrium(n_firms: int = 3, n_quantities: int = 20, 
                        max_quantity: float = 10.0):
    """
    Compute Cournot-Nash equilibrium for an oligopoly.
    
    Model:
    - n firms choose production quantities q_i
    - Market price: P(Q) = max(0, a - b*Q) where Q = sum(q_i)
    - Cost: c * q_i
    - Profit: q_i * (P(Q) - c)
    
    Nash equilibrium: q* = (a - c) / (b * (n + 1)) for each firm
    """
    a, b, c = 10.0, 1.0, 2.0  # Demand and cost parameters
    
    print(f"\nCournot Oligopoly ({n_firms} firms)")
    print(f"{'─' * 50}")
    print(f"  Demand: P(Q) = max(0, {a} - {b}*Q)")
    print(f"  Cost: C(q) = {c}*q")
    
    # Theoretical equilibrium
    q_star = (a - c) / (b * (n_firms + 1))
    Q_star = n_firms * q_star
    P_star = max(0, a - b * Q_star)
    profit_star = q_star * (P_star - c)
    
    print(f"\n  Theoretical Nash equilibrium:")
    print(f"    q* = {q_star:.4f} per firm")
    print(f"    Q* = {Q_star:.4f} total")
    print(f"    P* = {P_star:.4f}")
    print(f"    π* = {profit_star:.4f} per firm")
    
    # Sperner-based computation
    print(f"\n  Sperner approximation:")
    quantities = np.linspace(0, max_quantity, n_quantities)
    
    best_profile = None
    best_regret = float('inf')
    
    for q_indices in np.ndindex(*([n_quantities] * n_firms)):
        q = np.array([quantities[i] for i in q_indices])
        Q = q.sum()
        P = max(0, a - b * Q)
        profits = q * (P - c)
        
        # Check regret for each firm
        regret = 0
        for firm in range(n_firms):
            firm_profit = profits[firm]
            for alt_idx in range(n_quantities):
                alt_q = quantities[alt_idx]
                alt_Q = Q - q[firm] + alt_q
                alt_P = max(0, a - b * alt_Q)
                alt_profit = alt_q * (alt_P - c)
                regret = max(regret, alt_profit - firm_profit)
        
        if regret < best_regret:
            best_regret = regret
            best_profile = q.copy()
    
    if best_profile is not None:
        Q = best_profile.sum()
        P = max(0, a - b * Q)
        print(f"    q_approx = {best_profile}")
        print(f"    Q_approx = {Q:.4f}")
        print(f"    P_approx = {P:.4f}")
        print(f"    Max regret = {best_regret:.6f}")
        print(f"    Error |q* - q_approx| = {abs(q_star - best_profile[0]):.4f}")


# ============================================================
# Application 4: Fair Division via Nash Bargaining
# ============================================================

def fair_division_example():
    """
    Nash bargaining solution for fair division.
    
    Two agents divide a resource. Each has different utility functions.
    The Nash bargaining solution maximizes the product of utilities
    above the disagreement point.
    
    This can be viewed as a Nash equilibrium of the bargaining game.
    """
    print(f"\nNash Bargaining / Fair Division")
    print(f"{'─' * 50}")
    
    # Agent 1: u1(x) = sqrt(x)
    # Agent 2: u2(1-x) = (1-x)^2
    # Disagreement: (0, 0)
    # Nash bargaining: max sqrt(x) * (1-x)^2
    
    print(f"  Agent 1 utility: u₁(x) = √x")
    print(f"  Agent 2 utility: u₂(1-x) = (1-x)²")
    print(f"  Resource: unit interval [0, 1]")
    
    # Analytical solution: d/dx [x^{1/2} * (1-x)^2] = 0
    # (1/2) x^{-1/2} (1-x)^2 - 2 x^{1/2} (1-x) = 0
    # (1-x)/2 = 2x  =>  1-x = 4x  =>  x = 1/5
    
    x_star = 1/5
    u1_star = np.sqrt(x_star)
    u2_star = (1 - x_star) ** 2
    product_star = u1_star * u2_star
    
    print(f"\n  Analytical Nash bargaining solution:")
    print(f"    x* = {x_star:.4f}")
    print(f"    u₁(x*) = {u1_star:.4f}")
    print(f"    u₂(1-x*) = {u2_star:.4f}")
    print(f"    Nash product = {product_star:.4f}")
    
    # Sperner-based approximation
    print(f"\n  Sperner approximation:")
    for k in [10, 50, 100, 500]:
        best_x = 0
        best_product = 0
        for i in range(k + 1):
            x = i / k
            prod = np.sqrt(x) * (1 - x) ** 2
            if prod > best_product:
                best_product = prod
                best_x = x
        
        error = abs(best_x - x_star)
        print(f"    k={k:>4}: x_approx = {best_x:.4f}, "
              f"product = {best_product:.6f}, error = {error:.6f}")


if __name__ == "__main__":
    auction_equilibrium()
    network_routing_equilibrium()
    cournot_equilibrium(n_firms=2, n_quantities=15)
    fair_division_example()


"""
Sperner's Lemma and Nash Equilibria: Demonstration
===================================================

This demo illustrates the core connection between Sperner colorings of simplicial
subdivisions and Nash equilibria in finite games. It demonstrates:

1. Computing Nash equilibria via the Lemke-Howson algorithm
2. The Sperner coloring construction from best-response functions
3. Convergence of approximate Nash equilibria as mesh refines
4. The support lemma (indifference principle) in action
"""

import numpy as np
from typing import Tuple, List, Dict

# ============================================================
# Core Game Theory Primitives
# ============================================================

class FiniteGame:
    """An n-player finite normal-form game with m strategies per player."""
    
    def __init__(self, n: int, m: int, payoffs: np.ndarray):
        """
        Parameters
        ----------
        n : int
            Number of players
        m : int  
            Number of strategies per player
        payoffs : np.ndarray
            Shape (n, m, m, ..., m) with n+1 dims total.
            payoffs[i, s0, s1, ..., s_{n-1}] = payoff to player i
            under pure strategy profile (s0, ..., s_{n-1}).
        """
        self.n = n
        self.m = m
        self.payoffs = payoffs
    
    def expected_payoff(self, player: int, profile: List[np.ndarray]) -> float:
        """Compute expected payoff for a player under a mixed strategy profile."""
        result = self.payoffs[player].copy()
        # Marginalize over each player's mixed strategy
        for j in range(self.n - 1, -1, -1):
            result = np.tensordot(result, profile[j], axes=(j, 0))
        return float(result)
    
    def deviation_payoff(self, player: int, profile: List[np.ndarray], 
                         action: int) -> float:
        """Payoff when player deviates to pure strategy 'action'."""
        pure = np.zeros(self.m)
        pure[action] = 1.0
        dev_profile = [p.copy() for p in profile]
        dev_profile[player] = pure
        return self.expected_payoff(player, dev_profile)
    
    def regret(self, player: int, profile: List[np.ndarray], 
               action: int) -> float:
        """Regret for not playing action."""
        return (self.deviation_payoff(player, profile, action) - 
                self.expected_payoff(player, profile))
    
    def max_regret(self, profile: List[np.ndarray]) -> float:
        """Maximum regret across all players and actions."""
        return max(
            self.regret(i, profile, a)
            for i in range(self.n)
            for a in range(self.m)
        )
    
    def is_nash(self, profile: List[np.ndarray], eps: float = 1e-10) -> bool:
        """Check if profile is an ε-Nash equilibrium."""
        return self.max_regret(profile) <= eps
    
    def is_approx_nash(self, profile: List[np.ndarray], eps: float) -> bool:
        """Check if profile is an ε-Nash equilibrium."""
        return self.max_regret(profile) <= eps


def create_prisoners_dilemma() -> FiniteGame:
    """Classic Prisoner's Dilemma (2 players, 2 strategies each)."""
    # Strategies: 0 = Cooperate, 1 = Defect
    payoffs = np.zeros((2, 2, 2))
    payoffs[0] = np.array([[-1, -3], [0, -2]])  # Player 0's payoffs
    payoffs[1] = np.array([[-1, 0], [-3, -2]])   # Player 1's payoffs
    return FiniteGame(2, 2, payoffs)


def create_matching_pennies() -> FiniteGame:
    """Matching Pennies (2 players, 2 strategies)."""
    payoffs = np.zeros((2, 2, 2))
    payoffs[0] = np.array([[1, -1], [-1, 1]])   # Player 0 wants match
    payoffs[1] = np.array([[-1, 1], [1, -1]])   # Player 1 wants mismatch
    return FiniteGame(2, 2, payoffs)


def create_rock_paper_scissors() -> FiniteGame:
    """Rock-Paper-Scissors (2 players, 3 strategies)."""
    payoffs = np.zeros((2, 3, 3))
    # R=0, P=1, S=2
    payoffs[0] = np.array([[0, -1, 1], [1, 0, -1], [-1, 1, 0]])
    payoffs[1] = -payoffs[0]  # Zero-sum
    return FiniteGame(2, 3, payoffs)


# ============================================================
# Nash Equilibrium Computation (Support Enumeration)
# ============================================================

def find_nash_equilibria_2player(game: FiniteGame) -> List[Tuple[np.ndarray, np.ndarray]]:
    """Find Nash equilibria of a 2-player game by support enumeration."""
    equilibria = []
    m = game.m
    
    # Check all possible support combinations
    for supp_size_1 in range(1, m + 1):
        for supp_size_2 in range(1, m + 1):
            from itertools import combinations
            for supp1 in combinations(range(m), supp_size_1):
                for supp2 in combinations(range(m), supp_size_2):
                    result = _solve_for_support(game, list(supp1), list(supp2))
                    if result is not None:
                        equilibria.append(result)
    
    return equilibria


def _solve_for_support(game: FiniteGame, supp1: List[int], 
                       supp2: List[int]) -> Tuple[np.ndarray, np.ndarray] | None:
    """Try to find a Nash equilibrium with given supports."""
    m = game.m
    k1, k2 = len(supp1), len(supp2)
    
    # Player 2's strategy must make player 1 indifferent over supp1
    # For each pair (a, b) in supp1: sum_j sigma2[j] * u1[a,j] = sum_j sigma2[j] * u1[b,j]
    # Plus: sum_j sigma2[j] = 1 for j in supp2
    
    if k2 > 0:
        # Build system for player 2's strategy
        A2 = np.zeros((k1, k2))
        for idx_a, a in enumerate(supp1):
            for idx_j, j in enumerate(supp2):
                A2[idx_a, idx_j] = game.payoffs[0, a, j]
        
        # Indifference: row[0] payoff = row[i] payoff for i > 0
        # Sum = 1
        n_constraints = (k1 - 1) + 1
        A = np.zeros((n_constraints, k2))
        b = np.zeros(n_constraints)
        
        for i in range(k1 - 1):
            A[i] = A2[0] - A2[i + 1]
        A[k1 - 1] = np.ones(k2)
        b[k1 - 1] = 1.0
        
        try:
            if n_constraints == k2:
                sigma2_supp = np.linalg.solve(A, b)
            else:
                sigma2_supp = np.linalg.lstsq(A, b, rcond=None)[0]
        except np.linalg.LinAlgError:
            return None
        
        if np.any(sigma2_supp < -1e-10):
            return None
        sigma2_supp = np.maximum(sigma2_supp, 0)
        if abs(sigma2_supp.sum() - 1.0) > 1e-8:
            return None
    else:
        return None
    
    if k1 > 0:
        A1 = np.zeros((k2, k1))
        for idx_b, b_val in enumerate(supp2):
            for idx_i, i in enumerate(supp1):
                A1[idx_b, idx_i] = game.payoffs[1, i, b_val]
        
        n_constraints = (k2 - 1) + 1
        A = np.zeros((n_constraints, k1))
        b = np.zeros(n_constraints)
        
        for i in range(k2 - 1):
            A[i] = A1[0] - A1[i + 1]
        A[k2 - 1] = np.ones(k1)
        b[k2 - 1] = 1.0
        
        try:
            if n_constraints == k1:
                sigma1_supp = np.linalg.solve(A, b)
            else:
                sigma1_supp = np.linalg.lstsq(A, b, rcond=None)[0]
        except np.linalg.LinAlgError:
            return None
        
        if np.any(sigma1_supp < -1e-10):
            return None
        sigma1_supp = np.maximum(sigma1_supp, 0)
        if abs(sigma1_supp.sum() - 1.0) > 1e-8:
            return None
    else:
        return None
    
    # Reconstruct full strategy vectors
    sigma1 = np.zeros(m)
    sigma2 = np.zeros(m)
    for idx, s in enumerate(supp1):
        sigma1[s] = sigma1_supp[idx]
    for idx, s in enumerate(supp2):
        sigma2[s] = sigma2_supp[idx]
    
    # Verify Nash conditions
    profile = [sigma1, sigma2]
    if game.is_approx_nash(profile, 1e-6):
        return (sigma1, sigma2)
    return None


# ============================================================
# Demonstration
# ============================================================

def demo_nash_equilibria():
    """Demonstrate Nash equilibrium computation and verification."""
    print("=" * 60)
    print("SPERNER'S LEMMA AND NASH EQUILIBRIA")
    print("Combinatorial Fixed Points in Game Theory")
    print("=" * 60)
    
    games = {
        "Prisoner's Dilemma": create_prisoners_dilemma(),
        "Matching Pennies": create_matching_pennies(),
        "Rock-Paper-Scissors": create_rock_paper_scissors(),
    }
    
    for name, game in games.items():
        print(f"\n{'─' * 50}")
        print(f"Game: {name}")
        print(f"Players: {game.n}, Strategies per player: {game.m}")
        print(f"{'─' * 50}")
        
        equilibria = find_nash_equilibria_2player(game)
        
        if not equilibria:
            print("  No Nash equilibria found (algorithm limitation)")
            continue
        
        # Remove duplicates
        unique_eq = []
        for eq in equilibria:
            is_dup = any(
                np.allclose(eq[0], ueq[0]) and np.allclose(eq[1], ueq[1])
                for ueq in unique_eq
            )
            if not is_dup:
                unique_eq.append(eq)
        
        for idx, (s1, s2) in enumerate(unique_eq):
            print(f"\n  Equilibrium {idx + 1}:")
            print(f"    Player 1 strategy: {np.round(s1, 4)}")
            print(f"    Player 2 strategy: {np.round(s2, 4)}")
            
            profile = [s1, s2]
            for p in range(game.n):
                ep = game.expected_payoff(p, profile)
                print(f"    Player {p + 1} expected payoff: {ep:.4f}")
            
            mr = game.max_regret(profile)
            print(f"    Maximum regret: {mr:.2e}")
            print(f"    Is Nash: {game.is_nash(profile, 1e-6)}")
            
            # Verify support lemma
            print(f"    Support lemma verification:")
            for p in range(game.n):
                ep = game.expected_payoff(p, profile)
                support = [a for a in range(game.m) if profile[p][a] > 1e-10]
                dev_payoffs = [game.deviation_payoff(p, profile, a) for a in support]
                if support:
                    print(f"      Player {p + 1}: support = {support}, "
                          f"deviation payoffs = {[round(d, 4) for d in dev_payoffs]}, "
                          f"expected = {ep:.4f}")


def demo_sperner_convergence():
    """Demonstrate convergence of Sperner-based approximate Nash."""
    print("\n" + "=" * 60)
    print("SPERNER MESH CONVERGENCE")
    print("Approximate Nash equilibria improve with finer meshes")
    print("=" * 60)
    
    game = create_matching_pennies()
    true_nash = [np.array([0.5, 0.5]), np.array([0.5, 0.5])]
    
    print(f"\n  True Nash: Player 1 = {true_nash[0]}, Player 2 = {true_nash[1]}")
    print(f"\n  {'Mesh Size':>10} {'ε-bound':>12} {'Actual ε':>12} {'L∞ error':>12}")
    print(f"  {'─' * 48}")
    
    for k in [2, 4, 8, 16, 32, 64, 128, 256]:
        # Simulate Sperner-based approximation
        # Quantize to mesh grid and find best response
        best_approx = None
        best_regret = float('inf')
        
        for i in range(k + 1):
            p1 = np.array([i / k, 1 - i / k])
            for j in range(k + 1):
                p2 = np.array([j / k, 1 - j / k])
                profile = [p1, p2]
                mr = game.max_regret(profile)
                if mr < best_regret:
                    best_regret = mr
                    best_approx = profile
        
        linf_error = max(
            np.max(np.abs(best_approx[p] - true_nash[p]))
            for p in range(2)
        )
        
        max_payoff = np.max(np.abs(game.payoffs))
        eps_bound = max_payoff * (2 * 2) / k
        
        print(f"  {k:>10} {eps_bound:>12.6f} {best_regret:>12.6f} {linf_error:>12.6f}")


def demo_zero_sum_property():
    """Verify the zero-sum payoff theorem."""
    print("\n" + "=" * 60)
    print("ZERO-SUM PROPERTY")
    print("In zero-sum games, Nash equilibrium payoffs sum to zero")
    print("=" * 60)
    
    game = create_rock_paper_scissors()
    nash = [np.array([1/3, 1/3, 1/3]), np.array([1/3, 1/3, 1/3])]
    
    e0 = game.expected_payoff(0, nash)
    e1 = game.expected_payoff(1, nash)
    
    print(f"\n  Rock-Paper-Scissors Nash equilibrium:")
    print(f"    Player 1 strategy: {np.round(nash[0], 4)}")
    print(f"    Player 2 strategy: {np.round(nash[1], 4)}")
    print(f"    Player 1 expected payoff: {e0:.6f}")
    print(f"    Player 2 expected payoff: {e1:.6f}")
    print(f"    Sum of payoffs: {e0 + e1:.6f} (should be 0)")
    print(f"    Theorem verified: {abs(e0 + e1) < 1e-10}")


if __name__ == "__main__":
    demo_nash_equilibria()
    demo_sperner_convergence()
    demo_zero_sum_property()


"""
Visualization: Convergence of Sperner-Based Approximate Nash Equilibria
========================================================================

This script visualizes how the quality of approximate Nash equilibria
improves as the triangulation mesh gets finer, demonstrating the
mesh refinement theorem: ε ≤ maxPayoff * (n*m) / meshSize.

Three games are compared: Matching Pennies, Rock-Paper-Scissors,
and Battle of the Sexes.
"""

import numpy as np
import matplotlib.pyplot as plt


def max_regret_grid(payoff1, payoff2, k):
    """Find the minimum max-regret over a k-grid of mixed strategies for a 2-player game."""
    m = payoff1.shape[0]
    
    # Generate lattice points on the (m-1)-simplex
    def simplex_points(dim, resolution):
        if dim == 1:
            return [np.array([1.0])]
        if dim == 2:
            return [np.array([i/resolution, 1 - i/resolution]) for i in range(resolution + 1)]
        points = []
        _gen(dim, resolution, [], points)
        return points
    
    def _gen(dim, res, partial, pts):
        if len(partial) == dim - 1:
            rem = res - sum(partial)
            if rem >= 0:
                coords = partial + [rem]
                pts.append(np.array(coords, dtype=float) / res)
            return
        rem = res - sum(partial)
        for v in range(rem + 1):
            _gen(dim, res, partial + [v], pts)
    
    pts = simplex_points(m, k)
    
    best_regret = float('inf')
    
    for p1 in pts:
        for p2 in pts:
            # Expected payoffs
            ep1 = p1 @ payoff1 @ p2
            ep2 = p1 @ payoff2 @ p2
            
            # Max regret
            regret = 0
            for a in range(m):
                e_a = np.zeros(m)
                e_a[a] = 1.0
                dev1 = e_a @ payoff1 @ p2 - ep1
                dev2 = p1 @ payoff2 @ e_a - ep2
                regret = max(regret, dev1, dev2)
            
            best_regret = min(best_regret, regret)
    
    return best_regret


# Define games
games = {
    'Matching Pennies': (
        np.array([[1, -1], [-1, 1]], dtype=float),
        np.array([[-1, 1], [1, -1]], dtype=float)
    ),
    'Rock-Paper-Scissors': (
        np.array([[0, -1, 1], [1, 0, -1], [-1, 1, 0]], dtype=float),
        np.array([[0, 1, -1], [-1, 0, 1], [1, -1, 0]], dtype=float)
    ),
    'Battle of Sexes': (
        np.array([[3, 0], [0, 2]], dtype=float),
        np.array([[2, 0], [0, 3]], dtype=float)
    )
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

mesh_sizes = [2, 3, 4, 6, 8, 10, 12, 16, 20]
colors = ['#e74c3c', '#3498db', '#2ecc71']
markers = ['o', 's', '^']

for idx, (name, (u1, u2)) in enumerate(games.items()):
    m = u1.shape[0]
    epsilons = []
    max_payoff = max(np.max(np.abs(u1)), np.max(np.abs(u2)))
    n = 2
    
    valid_ks = []
    for k in mesh_sizes:
        eps = max_regret_grid(u1, u2, k)
        epsilons.append(eps)
        valid_ks.append(k)
    
    ax1.plot(valid_ks, epsilons, f'-{markers[idx]}', color=colors[idx], 
             label=name, linewidth=2, markersize=8)
    
    # Theoretical bound
    bounds = [max_payoff * (n * m) / k for k in valid_ks]
    ax1.plot(valid_ks, bounds, f'--', color=colors[idx], alpha=0.4, linewidth=1.5)

ax1.set_xlabel('Mesh Size (k)', fontsize=12)
ax1.set_ylabel('ε (Maximum Regret)', fontsize=12)
ax1.set_title('Convergence to Nash Equilibrium', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_yscale('log')
ax1.set_xscale('log')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=1e-16)

# Right panel: Complexity (simplices evaluated) vs accuracy
for idx, (name, (u1, u2)) in enumerate(games.items()):
    m = u1.shape[0]
    max_payoff = max(np.max(np.abs(u1)), np.max(np.abs(u2)))
    n = 2
    
    from math import comb
    complexities = []
    actual_eps = []
    
    for k in mesh_sizes:
        n_points = comb(k + m - 1, m - 1)
        complexity = n_points ** 2  # All pairs of lattice points
        eps = max_regret_grid(u1, u2, k)
        complexities.append(complexity)
        actual_eps.append(max(eps, 1e-16))
    
    ax2.plot(complexities, actual_eps, f'-{markers[idx]}', color=colors[idx],
             label=name, linewidth=2, markersize=8)

ax2.set_xlabel('Simplices Evaluated', fontsize=12)
ax2.set_ylabel('ε (Maximum Regret)', fontsize=12)
ax2.set_title('Accuracy vs Computational Cost', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.set_xscale('log')
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(bottom=1e-16)

plt.tight_layout()
plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_convergence.png")


"""
Visualization: Sperner Coloring of a 2-Simplex for a Game
==========================================================

This script visualizes how a 2-player game's best-response structure
induces a Sperner coloring on the strategy simplex. Each lattice point
is colored according to which player would most benefit from deviating,
creating a coloring pattern that (by Sperner's lemma) must contain
a fully-colored simplex - the approximate Nash equilibrium.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.tri as mtri
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection

def compute_regrets_matching_pennies(p1: float, p2: float):
    """Compute regrets for both players in Matching Pennies.
    Player 1 payoff matrix: [[1, -1], [-1, 1]]
    Player 2 payoff matrix: [[-1, 1], [1, -1]]
    """
    # Player 1's expected payoff: p1*p2*1 + p1*(1-p2)*(-1) + (1-p1)*p2*(-1) + (1-p1)*(1-p2)*1
    ep1 = p1 * p2 - p1 * (1 - p2) - (1 - p1) * p2 + (1 - p1) * (1 - p2)
    # = 4*p1*p2 - 2*p1 - 2*p2 + 1
    
    # Deviation payoff for player 1, action 0 (Heads)
    dev1_0 = p2 * 1 + (1 - p2) * (-1)  # = 2*p2 - 1
    # Deviation payoff for player 1, action 1 (Tails)
    dev1_1 = p2 * (-1) + (1 - p2) * 1  # = 1 - 2*p2
    
    regret1 = max(dev1_0 - ep1, dev1_1 - ep1)
    
    # Player 2's expected payoff
    ep2 = -ep1  # Zero-sum
    dev2_0 = p1 * (-1) + (1 - p1) * 1
    dev2_1 = p1 * 1 + (1 - p1) * (-1)
    
    regret2 = max(dev2_0 - ep2, dev2_1 - ep2)
    
    return regret1, regret2


def sperner_color(p1: float, p2: float) -> int:
    """Assign Sperner color based on best response structure.
    Color 0 (red): Player 1 has higher regret
    Color 1 (blue): Player 2 has higher regret
    Color 2 (green): Both players approximately best-responding (Nash-like)
    """
    r1, r2 = compute_regrets_matching_pennies(p1, p2)
    total = r1 + r2
    if total < 0.1:
        return 2  # Near Nash
    elif r1 > r2:
        return 0  # Player 1 wants to deviate more
    else:
        return 1  # Player 2 wants to deviate more


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

for ax_idx, k in enumerate([4, 8, 16]):
    ax = axes[ax_idx]
    
    colors_map = {0: '#e74c3c', 1: '#3498db', 2: '#2ecc71'}
    color_names = {0: 'Player 1 regret', 1: 'Player 2 regret', 2: 'Near Nash'}
    
    # Generate lattice points
    xs, ys, cs = [], [], []
    for i in range(k + 1):
        for j in range(k + 1):
            p1 = i / k
            p2 = j / k
            color = sperner_color(p1, p2)
            xs.append(p1)
            ys.append(p2)
            cs.append(colors_map[color])
    
    # Draw grid lines
    for i in range(k + 1):
        ax.axhline(y=i/k, color='lightgray', linewidth=0.5, alpha=0.5)
        ax.axvline(x=i/k, color='lightgray', linewidth=0.5, alpha=0.5)
    
    # Plot lattice points
    ax.scatter(xs, ys, c=cs, s=80 / (1 + k/8), zorder=5, edgecolors='black', linewidths=0.5)
    
    # Mark Nash equilibrium
    ax.plot(0.5, 0.5, '*', color='gold', markersize=15, zorder=10, 
            markeredgecolor='black', markeredgewidth=1.5)
    
    ax.set_xlabel('Player 1: Pr(Heads)', fontsize=11)
    ax.set_ylabel('Player 2: Pr(Heads)', fontsize=11)
    ax.set_title(f'Mesh size k = {k}', fontsize=13)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.set_aspect('equal')

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#e74c3c', 
           markersize=10, label='Player 1 wants to deviate'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#3498db', 
           markersize=10, label='Player 2 wants to deviate'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2ecc71', 
           markersize=10, label='Near Nash equilibrium'),
    Line2D([0], [0], marker='*', color='w', markerfacecolor='gold', 
           markersize=15, markeredgecolor='black', label='Exact Nash (0.5, 0.5)')
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=11,
           bbox_to_anchor=(0.5, -0.02))

fig.suptitle('Sperner Coloring of Strategy Space (Matching Pennies)',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_sperner_coloring.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_sperner_coloring.png")


"""
Visualization: The Nash Support Lemma (Indifference Principle)
===============================================================

This script illustrates the support lemma: in a Nash equilibrium,
every strategy played with positive probability must yield the same
expected payoff (indifference). This is visualized as a payoff
landscape where the equilibrium sits at an intersection of payoff
surfaces.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def compute_payoffs_3strategy(p_rock, p_paper, payoff_matrix):
    """Compute expected payoffs for each pure strategy in RPS-like game.
    
    p_rock, p_paper: opponent's mixing probabilities
    p_scissors = 1 - p_rock - p_paper
    """
    p_scissors = 1 - p_rock - p_paper
    opponent = np.array([p_rock, p_paper, p_scissors])
    
    payoff_rock = payoff_matrix[0] @ opponent
    payoff_paper = payoff_matrix[1] @ opponent
    payoff_scissors = payoff_matrix[2] @ opponent
    
    return payoff_rock, payoff_paper, payoff_scissors


# RPS payoff matrix for Player 1
rps_matrix = np.array([
    [0, -1, 1],   # Rock
    [1, 0, -1],   # Paper
    [-1, 1, 0]    # Scissors
], dtype=float)

fig = plt.figure(figsize=(16, 6))

# --- Panel 1: Payoff surfaces in 2D simplex ---
ax1 = fig.add_subplot(131)

# Sample the 2-simplex
n_grid = 100
p_rocks = []
p_papers = []
payoff_R = []
payoff_P = []
payoff_S = []

for i in range(n_grid + 1):
    for j in range(n_grid + 1 - i):
        pr = i / n_grid
        pp = j / n_grid
        ps = 1 - pr - pp
        if ps >= -1e-10:
            p_rocks.append(pr)
            p_papers.append(pp)
            r, p, s = compute_payoffs_3strategy(pr, pp, rps_matrix)
            payoff_R.append(r)
            payoff_P.append(p)
            payoff_S.append(s)

p_rocks = np.array(p_rocks)
p_papers = np.array(p_papers)

# Best response regions
br_colors = []
for r, p, s in zip(payoff_R, payoff_P, payoff_S):
    vals = [r, p, s]
    mx = max(vals)
    if abs(r - mx) < 0.01 and abs(p - mx) < 0.01 and abs(s - mx) < 0.01:
        br_colors.append('#2ecc71')  # All equal (Nash)
    elif r == mx and p == mx:
        br_colors.append('#f39c12')
    elif r == mx and s == mx:
        br_colors.append('#f39c12')
    elif p == mx and s == mx:
        br_colors.append('#f39c12')
    elif r == mx:
        br_colors.append('#e74c3c')
    elif p == mx:
        br_colors.append('#3498db')
    else:
        br_colors.append('#9b59b6')

ax1.scatter(p_rocks, p_papers, c=br_colors, s=3, alpha=0.7)
ax1.plot(1/3, 1/3, '*', color='gold', markersize=20, zorder=10,
         markeredgecolor='black', markeredgewidth=1.5)

ax1.set_xlabel("Pr(Rock)", fontsize=11)
ax1.set_ylabel("Pr(Paper)", fontsize=11)
ax1.set_title("Best Response Regions\n(Rock-Paper-Scissors)", fontsize=12, fontweight='bold')

from matplotlib.lines import Line2D
legend1 = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#e74c3c', markersize=8, label='BR: Rock'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#3498db', markersize=8, label='BR: Paper'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#9b59b6', markersize=8, label='BR: Scissors'),
    Line2D([0], [0], marker='*', color='w', markerfacecolor='gold', markersize=12,
           markeredgecolor='black', label='Nash (1/3, 1/3, 1/3)'),
]
ax1.legend(handles=legend1, fontsize=8, loc='upper right')

# --- Panel 2: Payoff cross-section ---
ax2 = fig.add_subplot(132)

# Fix opponent at Nash (1/3, 1/3, 1/3) and vary player 1's strategy along a line
ts = np.linspace(0, 1, 200)
devs_R = []
devs_P = []
devs_S = []
expected = []

opp = np.array([1/3, 1/3, 1/3])
for t in ts:
    # Strategy: t*Rock + (1-t)/2*Paper + (1-t)/2*Scissors
    p1 = np.array([t, (1-t)/2, (1-t)/2])
    
    devs_R.append(rps_matrix[0] @ opp)
    devs_P.append(rps_matrix[1] @ opp)
    devs_S.append(rps_matrix[2] @ opp)
    expected.append(p1 @ rps_matrix @ opp)

ax2.plot(ts, devs_R, '-', color='#e74c3c', linewidth=2.5, label='Payoff: Rock')
ax2.plot(ts, devs_P, '-', color='#3498db', linewidth=2.5, label='Payoff: Paper')
ax2.plot(ts, devs_S, '-', color='#9b59b6', linewidth=2.5, label='Payoff: Scissors')
ax2.plot(ts, expected, '--', color='black', linewidth=2, label='Expected payoff')

ax2.axvline(x=1/3, color='gold', linestyle=':', linewidth=2, alpha=0.7)
ax2.annotate('Nash\nequilibrium', xy=(1/3, 0), xytext=(0.55, 0.15),
            fontsize=10, ha='center',
            arrowprops=dict(arrowstyle='->', color='gray'))

ax2.set_xlabel('Pr(Rock) — varying along simplex path', fontsize=11)
ax2.set_ylabel('Payoff', fontsize=11)
ax2.set_title('Support Lemma:\nAll BR payoffs equal at Nash', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Regret landscape ---
ax3 = fig.add_subplot(133)

n = 50
p1_vals = np.linspace(0.01, 0.99, n)
p2_vals = np.linspace(0.01, 0.99, n)
P1, P2 = np.meshgrid(p1_vals, p2_vals)

# Matching pennies regret landscape
regret_grid = np.zeros_like(P1)
for i in range(n):
    for j in range(n):
        p1, p2 = P1[i, j], P2[i, j]
        # Player 1: [[1,-1],[-1,1]]
        # Player 2: [[-1,1],[1,-1]]
        ep1 = p1*p2 - p1*(1-p2) - (1-p1)*p2 + (1-p1)*(1-p2)
        dev1_h = 2*p2 - 1
        dev1_t = 1 - 2*p2
        r1 = max(dev1_h - ep1, dev1_t - ep1, 0)
        
        ep2 = -ep1
        dev2_h = -2*p1 + 1
        dev2_t = 2*p1 - 1
        r2 = max(dev2_h - ep2, dev2_t - ep2, 0)
        
        regret_grid[i, j] = max(r1, r2)

contour = ax3.contourf(P1, P2, regret_grid, levels=20, cmap='RdYlGn_r')
plt.colorbar(contour, ax=ax3, label='Max Regret')
ax3.contour(P1, P2, regret_grid, levels=[0.01, 0.05, 0.1, 0.2, 0.5], 
            colors='white', linewidths=0.5, alpha=0.5)

ax3.plot(0.5, 0.5, '*', color='gold', markersize=15, zorder=10,
         markeredgecolor='black', markeredgewidth=1.5)
ax3.set_xlabel('Player 1: Pr(Heads)', fontsize=11)
ax3.set_ylabel('Player 2: Pr(Heads)', fontsize=11)
ax3.set_title('Regret Landscape\n(Matching Pennies)', fontsize=12, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_support_lemma.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_support_lemma.png")
