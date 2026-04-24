"""Unit tests for the Crystalline framework.

Run with:
    python -m pytest tests/test_crystalline.py -v
"""

import math
import unittest

import torch
import torch.nn as nn

from crystalline.core import (
    tropical_add,
    tropical_mul,
    tropical_matmul,
    tropical_state_update,
    tropical_dot_product,
)
from crystalline.crystallize import (
    crystallization_penalty,
    sheffer_nand,
    tropical_to_sheffer,
    crystallize_tensor,
    crystallize_module,
)
from crystalline.deltanet import CrystallineDeltaLayer
from crystalline.moe import CrystallineRouter, CrystallineMoELayer
from crystalline.model import CrystallineModel, CrystallineConfig


try:
    from crystalline.triton_kernels import TRITON_AVAILABLE, triton_tropical_matmul
except ImportError:
    TRITON_AVAILABLE = False


class TestTropicalPrimitives(unittest.TestCase):
    def test_tropical_add(self):
        a = torch.tensor([1.0, 3.0])
        b = torch.tensor([2.0, 2.0])
        out = tropical_add(a, b)
        expected = torch.tensor([1.0, 2.0])
        self.assertTrue(torch.allclose(out, expected))

    def test_tropical_mul(self):
        a = torch.tensor([1.0, 3.0])
        b = torch.tensor([2.0, 2.0])
        out = tropical_mul(a, b)
        expected = torch.tensor([3.0, 5.0])
        self.assertTrue(torch.allclose(out, expected))

    def test_tropical_matmul_shape(self):
        A = torch.randn(4, 16)
        B = torch.randn(16, 8)
        out = tropical_matmul(A, B)
        self.assertEqual(out.shape, (4, 8))

    def test_tropical_matmul_correctness(self):
        A = torch.tensor([[1.0, 2.0], [3.0, 4.0]])
        B = torch.tensor([[0.5, 1.5], [2.0, 0.0]])
        out = tropical_matmul(A, B)
        expected = torch.tensor([
            [min(1.0 + 0.5, 2.0 + 2.0), min(1.0 + 1.5, 2.0 + 0.0)],
            [min(3.0 + 0.5, 4.0 + 2.0), min(3.0 + 1.5, 4.0 + 0.0)],
        ])
        self.assertTrue(torch.allclose(out, expected))

    def test_tropical_state_update_shape(self):
        state = torch.randn(2, 8)
        gate = torch.randn(2, 8)
        input_term = torch.randn(2, 8)
        out = tropical_state_update(state, gate, input_term)
        self.assertEqual(out.shape, (2, 8))

    def test_tropical_dot_product_shape(self):
        q = torch.randn(2, 4, 8, 16)
        k = torch.randn(2, 4, 8, 16)
        out = tropical_dot_product(q, k)
        self.assertEqual(out.shape, (2, 4, 8, 8))

    def test_tropical_dot_product_symmetry(self):
        q = torch.randn(2, 4, 8, 16)
        out = tropical_dot_product(q, q)
        diag = torch.diagonal(out, dim1=-2, dim2=-1)
        self.assertTrue(torch.allclose(diag, torch.zeros_like(diag), atol=1e-5))


class TestCrystallization(unittest.TestCase):
    def test_penalty_zero_at_integers(self):
        w = torch.tensor([-1.0, 0.0, 1.0])
        penalty = crystallization_penalty(w)
        self.assertAlmostEqual(penalty.item(), 0.0, places=5)

    def test_penalty_nonzero_elsewhere(self):
        w = torch.tensor([0.5])
        penalty = crystallization_penalty(w)
        self.assertGreater(penalty.item(), 0.0)

    def test_sheffer_nand(self):
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

    def test_crystallize_tensor(self):
        w = torch.tensor([-0.7, 0.2, 1.4, -0.3])
        crystallize_tensor(w)
        unique = torch.unique(w).tolist()
        self.assertTrue(all(v in [-1.0, 0.0, 1.0] for v in unique))

    def test_crystallize_module(self):
        m = nn.Linear(4, 4)
        crystallize_module(m)
        for p in m.parameters():
            unique = torch.unique(p).tolist()
            self.assertTrue(all(v in [-1.0, 0.0, 1.0] for v in unique))


class TestCrystallineDeltaLayer(unittest.TestCase):
    def test_forward_shape(self):
        layer = CrystallineDeltaLayer(d_model=64, num_heads=4)
        x = torch.randn(2, 10, 64)
        out = layer(x)
        self.assertEqual(out.shape, (2, 10, 64))

    def test_no_nan(self):
        layer = CrystallineDeltaLayer(d_model=64, num_heads=4)
        x = torch.randn(2, 5, 64)
        out = layer(x)
        self.assertFalse(torch.isnan(out).any())


class TestCrystallineMoE(unittest.TestCase):
    def test_router_shape(self):
        router = CrystallineRouter(d_model=64, num_experts=8, top_k=2)
        x = torch.randn(2, 10, 64)
        indices, weights = router(x)
        self.assertEqual(indices.shape, (2, 10, 2))
        self.assertEqual(weights.shape, (2, 10, 2))
        self.assertTrue((weights.sum(dim=-1) - 1.0).abs().max() < 1e-3)

    def test_moe_forward_shape(self):
        moe = CrystallineMoELayer(d_model=64, d_ff=128, num_experts=4, top_k=2)
        x = torch.randn(2, 5, 64)
        out = moe(x)
        self.assertEqual(out.shape, (2, 5, 64))


class TestCrystallineModel(unittest.TestCase):
    def test_forward_shape(self):
        config = CrystallineConfig(
            vocab_size=128,
            d_model=64,
            num_layers=2,
            num_heads=4,
            d_ff=128,
            max_seq_len=128,
        )
        model = CrystallineModel(config)
        input_ids = torch.randint(0, 128, (2, 16))
        logits = model(input_ids)
        self.assertEqual(logits.shape, (2, 16, 128))

    def test_forward_with_labels(self):
        config = CrystallineConfig(
            vocab_size=128,
            d_model=64,
            num_layers=2,
            num_heads=4,
            d_ff=128,
            max_seq_len=128,
        )
        model = CrystallineModel(config)
        input_ids = torch.randint(0, 128, (2, 16))
        labels = input_ids.clone()
        logits, loss = model(input_ids, labels=labels)
        self.assertEqual(logits.shape, (2, 16, 128))
        self.assertTrue(loss.item() > 0)

    def test_crystallize(self):
        config = CrystallineConfig(
            vocab_size=128,
            d_model=64,
            num_layers=2,
            num_heads=4,
            d_ff=128,
        )
        model = CrystallineModel(config)
        model.crystallize()
        for p in model.parameters():
            unique = torch.unique(p).tolist()
            self.assertTrue(all(v in [-1.0, 0.0, 1.0] for v in unique))

    def test_generate(self):
        config = CrystallineConfig(
            vocab_size=64,
            d_model=32,
            num_layers=2,
            num_heads=4,
            d_ff=64,
            max_seq_len=64,
        )
        model = CrystallineModel(config)
        input_ids = torch.randint(0, 64, (1, 8))
        output = model.generate(input_ids, max_new_tokens=10)
        self.assertEqual(output.shape, (1, 18))


class TestTritonKernels(unittest.TestCase):
    @unittest.skipIf(not TRITON_AVAILABLE, "Triton not available")
    def test_triton_matmul(self):
        A = torch.randn(128, 256, device="cuda")
        B = torch.randn(256, 64, device="cuda")
        C = triton_tropical_matmul(A, B)
        ref = torch.min(A.unsqueeze(-1) + B.unsqueeze(0), dim=1)[0]
        self.assertTrue(torch.allclose(C, ref))


class TestIntegration(unittest.TestCase):
    def test_full_pipeline(self):
        """Run a mini forward pass through crystallized model."""
        config = CrystallineConfig(
            vocab_size=64,
            d_model=32,
            num_layers=2,
            num_heads=4,
            d_ff=64,
            max_seq_len=64,
            use_delta_net=True,
        )
        model = CrystallineModel(config)
        input_ids = torch.randint(0, 64, (2, 8))
        logits = model(input_ids)
        self.assertEqual(logits.shape, (2, 8, 64))

        model.crystallize()
        logits2 = model(input_ids)
        self.assertEqual(logits2.shape, (2, 8, 64))


if __name__ == "__main__":
    unittest.main(verbosity=2)
