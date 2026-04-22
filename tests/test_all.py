"""Unit tests for qwen_optimizer package.

Run with:
    python -m pytest tests/ -v
    or
    python tests/test_all.py
"""

import unittest

import torch
import torch.nn as nn

from qwen_optimizer.tropical import (
    TropicalModel,
    TropicalLinear,
    TropicalAttention,
    TropicalFFN,
    tropical_matmul,
    tropical_dot_product,
    crystallization_penalty,
    sheffer_nand,
    tropical_to_sheffer,
    convert_to_tropical,
)
from qwen_optimizer.prune import (
    prune_ffn_intermediate,
    unstructured_magnitude_prune,
    compute_sparsity,
    prune_model,
)

try:
    from qwen_optimizer.triton_kernels import TRITON_AVAILABLE, triton_tropical_matmul, triton_tropical_l1_distance
except ImportError:
    TRITON_AVAILABLE = False


class TestTropicalPrimitives(unittest.TestCase):
    def test_tropical_matmul_shape(self):
        x = torch.randn(4, 16)
        W = torch.randn(16, 8)
        out = tropical_matmul(x, W)
        self.assertEqual(out.shape, (4, 8))

    def test_tropical_matmul_correctness(self):
        x = torch.tensor([[1.0, 2.0], [3.0, 4.0]])
        W = torch.tensor([[0.5, 1.5], [2.0, 0.0]])
        out = tropical_matmul(x, W)
        # manual: min over k of x[i,k] + W[k,j]
        expected = torch.tensor([
            [min(1.0+0.5, 2.0+2.0), min(1.0+1.5, 2.0+0.0)],
            [min(3.0+0.5, 4.0+2.0), min(3.0+1.5, 4.0+0.0)],
        ])
        self.assertTrue(torch.allclose(out, expected))

    def test_tropical_dot_product_shape(self):
        q = torch.randn(2, 4, 8, 16)
        k = torch.randn(2, 4, 8, 16)
        out = tropical_dot_product(q, k)
        self.assertEqual(out.shape, (2, 4, 8, 8))

    def test_tropical_dot_product_symmetry(self):
        q = torch.randn(2, 4, 8, 16)
        out = tropical_dot_product(q, q)
        # Diagonal should be 0 (distance from self)
        diag = torch.diagonal(out, dim1=-2, dim2=-1)
        self.assertTrue(torch.allclose(diag, torch.zeros_like(diag), atol=1e-5))


class TestTropicalLinear(unittest.TestCase):
    def test_forward_shape(self):
        layer = TropicalLinear(16, 8)
        x = torch.randn(2, 4, 16)
        out = layer(x)
        self.assertEqual(out.shape, (2, 4, 8))

    def test_no_multiplications(self):
        layer = TropicalLinear(16, 8, bias=False)
        # Tropical linear uses only addition and min
        x = torch.randn(2, 16)
        out = layer(x)
        self.assertEqual(out.shape, (2, 8))

    def test_bias(self):
        layer = TropicalLinear(16, 8, bias=True)
        x = torch.randn(2, 16)
        out = layer(x)
        self.assertEqual(out.shape, (2, 8))


class TestTropicalAttention(unittest.TestCase):
    def test_forward_shape(self):
        attn = TropicalAttention(embed_dim=64, num_heads=4)
        x = torch.randn(2, 10, 64)
        out, weights = attn(x, is_causal=True)
        self.assertEqual(out.shape, (2, 10, 64))
        self.assertIsNotNone(weights)
        self.assertEqual(weights.shape, (2, 4, 10, 10))

    def test_hard_attention(self):
        attn = TropicalAttention(embed_dim=64, num_heads=4, hard_attention=True)
        x = torch.randn(2, 10, 64)
        out, weights = attn(x, is_causal=True)
        self.assertEqual(out.shape, (2, 10, 64))
        self.assertIsNone(weights)

    def test_causal_mask(self):
        attn = TropicalAttention(embed_dim=64, num_heads=4, hard_attention=True)
        x = torch.randn(1, 5, 64)
        out, _ = attn(x, is_causal=True)
        # Just verify it runs without error and respects causality
        self.assertEqual(out.shape, (1, 5, 64))


class TestTropicalFFN(unittest.TestCase):
    def test_forward_shape(self):
        ffn = TropicalFFN(d_model=64, d_ff=256)
        x = torch.randn(2, 10, 64)
        out = ffn(x)
        self.assertEqual(out.shape, (2, 10, 64))


class TestTropicalModel(unittest.TestCase):
    def test_forward_shape(self):
        model = TropicalModel(
            vocab_size=128,
            d_model=64,
            num_layers=2,
            num_heads=4,
            d_ff=128,
            max_seq_len=128,
        )
        input_ids = torch.randint(0, 128, (2, 16))
        logits = model(input_ids, is_causal=True)
        self.assertEqual(logits.shape, (2, 16, 128))

    def test_crystallization(self):
        model = TropicalModel(
            vocab_size=128,
            d_model=64,
            num_layers=2,
            num_heads=4,
            d_ff=128,
        )
        model.crystallize()
        for p in model.parameters():
            unique = torch.unique(p).tolist()
            self.assertTrue(all(v in [-1.0, 0.0, 1.0] for v in unique))

    def test_count_multiplications(self):
        model = TropicalModel(
            vocab_size=128,
            d_model=64,
            num_layers=2,
            num_heads=4,
            d_ff=128,
        )
        count = model.count_multiplications()
        self.assertEqual(count, 0)


class TestCrystallization(unittest.TestCase):
    def test_penalty_zero_at_targets(self):
        w = torch.tensor([-1.0, 0.0, 1.0])
        penalty = crystallization_penalty(w)
        self.assertAlmostEqual(penalty.item(), 0.0, places=5)

    def test_penalty_nonzero_elsewhere(self):
        w = torch.tensor([0.5])
        penalty = crystallization_penalty(w)
        self.assertGreater(penalty.item(), 0.0)


class TestSheffer(unittest.TestCase):
    def test_nand_truth_table(self):
        a = torch.tensor([0.0, 0.0, 1.0, 1.0])
        b = torch.tensor([0.0, 1.0, 0.0, 1.0])
        out = sheffer_nand(a, b)
        expected = torch.tensor([1.0, 1.0, 1.0, 0.0])
        self.assertTrue(torch.allclose(out, expected))

    def test_tropical_to_sheffer(self):
        w = torch.tensor([-0.3, 0.4, 0.6, 1.2])
        out = tropical_to_sheffer(w, threshold=0.5)
        expected = torch.tensor([0.0, 0.0, 1.0, 1.0])
        self.assertTrue(torch.allclose(out, expected))


class TestConvertToTropical(unittest.TestCase):
    def test_extracts_config(self):
        class FakeConfig:
            vocab_size = 128
            hidden_size = 64
            num_hidden_layers = 2
            num_attention_heads = 4
            intermediate_size = 256
            max_position_embeddings = 512

        class FakeModel(nn.Module):
            def __init__(self):
                super().__init__()
                self.config = FakeConfig()
                self.embed = nn.Embedding(128, 64)

        fake = FakeModel()
        tropical = convert_to_tropical(fake)
        self.assertEqual(tropical.d_model, 64)
        self.assertEqual(tropical.num_layers, 2)


class TestPruning(unittest.TestCase):
    def test_unstructured_sparsity(self):
        mlp = nn.Sequential(nn.Linear(16, 32), nn.ReLU(), nn.Linear(32, 8))
        prune_model(mlp, unstructured_sparsity=0.5)
        sparsity = compute_sparsity(mlp)
        self.assertAlmostEqual(sparsity, 0.5, delta=0.02)

    def test_ffn_prune_changes_shape(self):
        class SimpleFFN(nn.Module):
            def __init__(self):
                super().__init__()
                self.fc1 = nn.Linear(16, 32)
                self.fc2 = nn.Linear(32, 16)

        ffn = SimpleFFN()
        original = ffn.fc1.weight.shape[0]
        prune_model(ffn, ffn_prune_ratio=0.3)
        new = ffn.fc1.weight.shape[0]
        self.assertLess(new, original)
        self.assertEqual(ffn.fc2.weight.shape[1], new)


@unittest.skipIf(not TRITON_AVAILABLE, "Triton not available")
class TestTritonKernels(unittest.TestCase):
    def test_triton_matmul(self):
        A = torch.randn(128, 256, device='cuda')
        B = torch.randn(256, 64, device='cuda')
        C = triton_tropical_matmul(A, B)
        ref = torch.min(A.unsqueeze(-1) + B.unsqueeze(0), dim=1)[0]
        self.assertTrue(torch.allclose(C, ref))

    def test_triton_l1_distance(self):
        Q = torch.randn(2, 4, 128, 64, device='cuda')
        K = torch.randn(2, 4, 128, 64, device='cuda')
        Out = triton_tropical_l1_distance(Q, K)
        ref = -torch.sum(torch.abs(Q.unsqueeze(-2) - K.unsqueeze(-3)), dim=-1)
        self.assertTrue(torch.allclose(Out, ref, atol=1e-5))


class TestIntegration(unittest.TestCase):
    def test_tropical_pipeline(self):
        """Run a mini forward pass through crystallized model."""
        model = TropicalModel(
            vocab_size=64,
            d_model=32,
            num_layers=2,
            num_heads=4,
            d_ff=64,
            max_seq_len=64,
            hard_attention=False,
        )
        input_ids = torch.randint(0, 64, (2, 8))
        logits = model(input_ids, is_causal=True)
        self.assertEqual(logits.shape, (2, 8, 64))

        model.crystallize()
        logits2 = model(input_ids, is_causal=True)
        self.assertEqual(logits2.shape, (2, 8, 64))


if __name__ == "__main__":
    unittest.main(verbosity=2)
