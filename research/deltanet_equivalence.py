"""Numerical experiments comparing standard DeltaNet vs tropical DeltaNet on random data.

Run: python research/deltanet_equivalence.py
"""

import math

import torch
import torch.nn as nn

from crystalline.core import tropical_state_update


class StandardDeltaLayer(nn.Module):
    """Standard DeltaNet recurrence: s_t = gate * s_{t-1} + k_t v_t^T."""

    def __init__(self, d_model, num_heads=4):
        super().__init__()
        self.d_model = d_model
        self.num_heads = num_heads
        self.head_dim = d_model // num_heads

        self.k_proj = nn.Linear(d_model, d_model, bias=False)
        self.v_proj = nn.Linear(d_model, d_model, bias=False)
        self.gate_proj = nn.Linear(d_model, num_heads, bias=False)

    def forward(self, x):
        B, T, D = x.shape
        K = self.k_proj(x).view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        V = self.v_proj(x).view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        gates = torch.sigmoid(self.gate_proj(x)).transpose(1, 2)  # (B, H, T)

        state = torch.zeros(B, self.num_heads, self.head_dim, device=x.device)
        outputs = []
        for t in range(T):
            k_t = K[:, :, t, :]  # (B, H, Hd)
            v_t = V[:, :, t, :]  # (B, H, Hd)
            g_t = gates[:, :, t].unsqueeze(-1)  # (B, H, 1)

            # Standard recurrence: s = gate * s + k * v (simplified element-wise)
            state = g_t * state + k_t * v_t
            outputs.append(state)

        return torch.stack(outputs, dim=2)  # (B, H, T, Hd)


class TropicalDeltaLayer(nn.Module):
    """Tropical DeltaNet recurrence: s_t = min(gate + s_{t-1}, k_t + v_t)."""

    def __init__(self, d_model, num_heads=4):
        super().__init__()
        self.d_model = d_model
        self.num_heads = num_heads
        self.head_dim = d_model // num_heads

        self.k_proj = nn.Linear(d_model, d_model, bias=False)
        self.v_proj = nn.Linear(d_model, d_model, bias=False)
        self.gate_proj = nn.Linear(d_model, num_heads, bias=False)

    def forward(self, x):
        B, T, D = x.shape
        K = self.k_proj(x).view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        V = self.v_proj(x).view(B, T, self.num_heads, self.head_dim).transpose(1, 2)
        gates = torch.tanh(self.gate_proj(x)).transpose(1, 2) * 2.0  # (B, H, T)

        state = torch.zeros(B, self.num_heads, self.head_dim, device=x.device)
        outputs = []
        for t in range(T):
            k_t = K[:, :, t, :]
            v_t = V[:, :, t, :]
            g_t = gates[:, :, t].unsqueeze(-1)  # (B, H, 1) to broadcast over head_dim

            # Tropical recurrence
            state = tropical_state_update(state, g_t, k_t + v_t)
            outputs.append(state)

        return torch.stack(outputs, dim=2)


def compute_mse(a, b):
    return torch.mean((a - b) ** 2).item()


def run_experiments():
    print("=" * 60)
    print("DeltaNet Equivalence Experiments")
    print("=" * 60)

    configs = [
        {"d_model": 64, "num_heads": 4, "seq_len": 16, "batch": 2},
        {"d_model": 128, "num_heads": 8, "seq_len": 32, "batch": 2},
        {"d_model": 256, "num_heads": 8, "seq_len": 64, "batch": 4},
    ]

    for cfg in configs:
        print(f"\nConfig: d_model={cfg['d_model']}, heads={cfg['num_heads']}, seq={cfg['seq_len']}, batch={cfg['batch']}")

        std_layer = StandardDeltaLayer(cfg["d_model"], cfg["num_heads"])
        trop_layer = TropicalDeltaLayer(cfg["d_model"], cfg["num_heads"])

        # Copy weights so both layers see the same projections
        trop_layer.k_proj.weight.data.copy_(std_layer.k_proj.weight.data)
        trop_layer.v_proj.weight.data.copy_(std_layer.v_proj.weight.data)
        trop_layer.gate_proj.weight.data.copy_(std_layer.gate_proj.weight.data)

        x = torch.randn(cfg["batch"], cfg["seq_len"], cfg["d_model"])

        with torch.no_grad():
            std_out = std_layer(x)
            trop_out = trop_layer(x)

        mse = compute_mse(std_out, trop_out)
        print(f"  MSE between standard and tropical: {mse:.6f}")

        # Check that tropical preserves monotonicity (decay property)
        # In standard: if gate < 1, state shrinks. In tropical: if gate < 0, state decays.
        print(f"  Tropical output range: [{trop_out.min():.3f}, {trop_out.max():.3f}]")
        print(f"  Standard output range: [{std_out.min():.3f}, {std_out.max():.3f}]")

    print("\n" + "=" * 60)
    print("Done.")
    print("=" * 60)


if __name__ == "__main__":
    run_experiments()
