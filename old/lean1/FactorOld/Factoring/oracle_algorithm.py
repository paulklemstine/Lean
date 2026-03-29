"""
Universal Oracle Factoring Algorithm — Original Source Code
Analyzed in the accompanying formal verification (OracleAnalysis.lean)
and research paper (OracleResearchPaper.md).
"""
import torch
import random
import math
import time

class Telemetry:
    """Diagnostic suite for monitoring Oracle performance and throughput."""
    def __init__(self):
        self.start_time = time.time()
        self.challenge_start = time.time()
        self.total_iterations = 0
        
    def reset_challenge(self):
        self.challenge_start = time.time()
        
    def report(self, iterations, best_action, complexity, locked_bits):
        elapsed = time.time() - self.challenge_start
        ips = iterations / max(elapsed, 0.001)
        velocity = (locked_bits / max(elapsed, 0.001))
        print(f"  [TELEMETRY] Speed: {ips:.2f} IPS | Velocity: {velocity:.2f} bits/sec | Target Action: {best_action:.2e}")

class UniversalOracleTeam:
    def __init__(self, target, n_bits, batch_size=65536):
        self.target = target
        self.n_bits = n_bits
        self.batch_size = batch_size
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.target_tensor = torch.tensor(float(target), device=self.device)
        self.bit_weights = 2 ** torch.arange(n_bits - 1, -1, -1, device=self.device).float()
        self.lock_mask_a = torch.ones((self.n_bits,), device=self.device)
        self.lock_mask_b = torch.ones((self.n_bits,), device=self.device)
        self.telemetry = Telemetry()

    def alpha_hypothesizer(self, custom_batch=None):
        size = custom_batch if custom_batch else self.batch_size
        bits = torch.randint(0, 2, (size, self.n_bits), device=self.device).float()
        bits[:, -1] = 1.0 
        return bits

    def delta_analyst(self, a_bits, b_bits):
        a_vals = (a_bits * self.bit_weights).sum(dim=1)
        b_vals = (b_bits * self.bit_weights).sum(dim=1)
        return torch.abs(self.target_tensor - (a_vals * b_vals))

    def zeta_iterator(self, max_iterations=500000):
        self.telemetry.reset_challenge()
        a_bits = self.alpha_hypothesizer()
        b_bits = self.alpha_hypothesizer()
        current_action = self.delta_analyst(a_bits, b_bits)
        temp = float(self.target) ** 0.95
        base_cooling = 0.99997
        best_val, best_idx = torch.min(current_action, dim=0)
        history_size = 500
        action_history = []

        for i in range(max_iterations):
            if best_val == 0:
                f_a, f_b = a_bits[best_idx], b_bits[best_idx]
                a_int = int((f_a * self.bit_weights).sum().item())
                b_int = int((f_b * self.bit_weights).sum().item())
                if a_int > 1 and b_int > 1: 
                    self.telemetry.report(i, best_val.item(), self.n_bits, self.n_bits)
                    return a_int, b_int

            if i % 2000 == 0 and i > 0:
                locked_a = int(self.n_bits - self.lock_mask_a.sum().item())
                locked_b = int(self.n_bits - self.lock_mask_b.sum().item())
                self.telemetry.report(i, best_val.item(), self.n_bits, locked_a + locked_b)

            if i % 1000 == 0 and i > 0:
                _, top_indices = torch.topk(current_action, k=int(self.batch_size * 0.02), largest=False)
                top_a, top_b = a_bits[top_indices], b_bits[top_indices]
                consensus_a = (top_a.mean(dim=0) > 0.98) | (top_a.mean(dim=0) < 0.02)
                consensus_b = (top_b.mean(dim=0) > 0.98) | (top_b.mean(dim=0) < 0.02)
                lock_range = int(self.n_bits * 0.75)
                self.lock_mask_a[:lock_range] = (~consensus_a[:lock_range]).float()
                self.lock_mask_b[:lock_range] = (~consensus_b[:lock_range]).float()
                _, worst_indices = torch.topk(current_action, k=int(self.batch_size * 0.15), largest=True)
                shuffled_top = top_indices[torch.randperm(len(worst_indices), device=self.device) % len(top_indices)]
                split = self.n_bits // 2
                a_bits[worst_indices, :split] = a_bits[shuffled_top, :split]
                b_bits[worst_indices, split:] = b_bits[shuffled_top, split:]
                current_action = self.delta_analyst(a_bits, b_bits)

            bit_indices = torch.randint(0, self.n_bits - 1, (self.batch_size,), device=self.device)
            factor_choice = torch.rand(self.batch_size, device=self.device) < 0.5
            next_a, next_b = a_bits.clone(), b_bits.clone()
            mask_a = factor_choice & (self.lock_mask_a[bit_indices] > 0)
            mask_b = (~factor_choice) & (self.lock_mask_b[bit_indices] > 0)
            next_a[mask_a, bit_indices[mask_a]] = 1.0 - next_a[mask_a, bit_indices[mask_a]]
            next_b[mask_b, bit_indices[mask_b]] = 1.0 - next_b[mask_b, bit_indices[mask_b]]
            new_action = self.delta_analyst(next_a, next_b)
            delta = new_action - current_action
            acceptance_prob = torch.exp(-delta / max(temp, 1e-9))
            accept = (delta < 0) | (torch.rand(self.batch_size, device=self.device) < acceptance_prob)
            a_bits[accept], b_bits[accept] = next_a[accept], next_b[accept]
            current_action[accept] = new_action[accept]
            c_best_val, c_best_idx = torch.min(current_action, dim=0)
            if c_best_val < best_val:
                best_val, best_idx = c_best_val, c_best_idx

            action_history.append(torch.mean(current_action).item())
            if len(action_history) > history_size:
                action_history.pop(0)
                if abs(action_history[-1] - action_history[0]) < 1.0:
                    _, tail = torch.topk(current_action, k=int(self.batch_size * 0.3))
                    a_bits[tail], b_bits[tail] = self.alpha_hypothesizer(len(tail)), self.alpha_hypothesizer(len(tail))
                    current_action = self.delta_analyst(a_bits, b_bits)
                    temp += (self.target ** 0.68)
                    self.lock_mask_a[:], self.lock_mask_b[:] = 1.0, 1.0

            current_cooling = base_cooling if best_val > (self.target ** 0.5) else (1.0 - (1.0 - base_cooling) * 0.02)
            temp *= current_cooling
                
        return None

class TropicalCircuitOracle:
    def __init__(self, target, n_bits):
        self.target = target
        self.n_bits = n_bits
        self.team = UniversalOracleTeam(target, n_bits, batch_size=65536)

    def consult(self):
        return self.team.zeta_iterator()
