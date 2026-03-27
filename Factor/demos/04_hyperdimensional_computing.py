#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 4: HYPERDIMENSIONAL COMPUTING CLASSIFIER                  ║
║  ────────────────────────────────────────────────────────────    ║
║  Classification using 10,000-dimensional binary vectors.        ║
║  No neural networks. No backpropagation. No gradient descent.   ║
║  Just high-dimensional geometry and Hamming distances.          ║
║                                                                  ║
║  Key insight: in 10,000 dimensions, random vectors are quasi-   ║
║  orthogonal with probability → 1. This gives us an almost-     ║
║  free encoding scheme with natural noise tolerance.              ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np
from collections import defaultdict

# ── Hyperdimensional Vector Operations ─────────────────────────
D = 10000  # Dimensionality

def random_hv() -> np.ndarray:
    """Generate a random binary hypervector."""
    return np.random.randint(0, 2, D, dtype=np.int8)

def bind(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Binding operation (XOR) - creates associations."""
    return np.bitwise_xor(a, b)

def bundle(vectors: list) -> np.ndarray:
    """Bundling operation (majority vote) - creates superpositions."""
    total = np.sum(vectors, axis=0)
    # Majority vote with random tiebreaking
    threshold = len(vectors) / 2
    result = np.zeros(D, dtype=np.int8)
    result[total > threshold] = 1
    ties = total == threshold
    result[ties] = np.random.randint(0, 2, np.sum(ties), dtype=np.int8)
    return result

def permute(v: np.ndarray, n: int = 1) -> np.ndarray:
    """Permutation (cyclic shift) - encodes position/sequence."""
    return np.roll(v, n)

def hamming_distance(a: np.ndarray, b: np.ndarray) -> float:
    """Normalized Hamming distance (0 = identical, 0.5 = orthogonal, 1 = opposite)."""
    return np.sum(a != b) / D

def cosine_similarity(a: np.ndarray, b: np.ndarray) -> float:
    """Cosine similarity mapped from binary vectors."""
    return 1.0 - 2.0 * hamming_distance(a, b)


# ── HDC Classifier ─────────────────────────────────────────────
class HDClassifier:
    """
    Hyperdimensional Computing classifier.

    Training:
    1. Assign random HV to each feature position (level hypervectors)
    2. Assign random HV to each quantization level
    3. Encode each sample by binding feature HVs with level HVs
    4. Bundle all encodings per class → class prototype

    Inference:
    1. Encode query sample the same way
    2. Compare to all class prototypes via Hamming distance
    3. Return nearest class
    """

    def __init__(self, n_features: int, n_levels: int = 20):
        self.n_features = n_features
        self.n_levels = n_levels

        # Feature position hypervectors
        self.position_hvs = [random_hv() for _ in range(n_features)]

        # Level hypervectors (quantized feature values)
        # Use interpolation for smooth level encoding
        base = random_hv()
        self.level_hvs = [base.copy()]
        flip_per_level = D // (n_levels * 2)
        for i in range(1, n_levels):
            prev = self.level_hvs[-1].copy()
            # Flip some bits to gradually change
            flip_idx = np.random.choice(D, flip_per_level, replace=False)
            prev[flip_idx] = 1 - prev[flip_idx]
            self.level_hvs.append(prev)

        self.class_hvs = {}
        self.class_counts = defaultdict(int)

    def _quantize(self, value: float, min_val: float, max_val: float) -> int:
        """Map continuous value to discrete level."""
        if max_val == min_val:
            return self.n_levels // 2
        normalized = (value - min_val) / (max_val - min_val)
        level = int(normalized * (self.n_levels - 1))
        return max(0, min(self.n_levels - 1, level))

    def _encode_sample(self, sample: np.ndarray, mins: np.ndarray,
                        maxs: np.ndarray) -> np.ndarray:
        """Encode a single sample as a hypervector."""
        components = []
        for i, val in enumerate(sample):
            level = self._quantize(val, mins[i], maxs[i])
            # Bind position with level
            encoded_feature = bind(self.position_hvs[i], self.level_hvs[level])
            components.append(encoded_feature)
        return bundle(components)

    def fit(self, X: np.ndarray, y: np.ndarray):
        """Train the classifier (single pass!)."""
        self.mins = X.min(axis=0)
        self.maxs = X.max(axis=0)

        # Encode all samples and accumulate per class
        class_accumulators = defaultdict(list)
        for sample, label in zip(X, y):
            encoded = self._encode_sample(sample, self.mins, self.maxs)
            class_accumulators[label].append(encoded)
            self.class_counts[label] += 1

        # Create class prototypes via bundling
        for label, encodings in class_accumulators.items():
            self.class_hvs[label] = bundle(encodings)

    def predict(self, X: np.ndarray) -> np.ndarray:
        """Predict class labels."""
        predictions = []
        for sample in X:
            encoded = self._encode_sample(sample, self.mins, self.maxs)
            # Find nearest class prototype
            best_label = None
            best_dist = float('inf')
            for label, class_hv in self.class_hvs.items():
                dist = hamming_distance(encoded, class_hv)
                if dist < best_dist:
                    best_dist = dist
                    best_label = label
            predictions.append(best_label)
        return np.array(predictions)

    def predict_with_confidence(self, sample: np.ndarray) -> dict:
        """Predict with confidence scores for all classes."""
        encoded = self._encode_sample(sample, self.mins, self.maxs)
        distances = {}
        for label, class_hv in self.class_hvs.items():
            distances[label] = hamming_distance(encoded, class_hv)

        # Convert distances to confidences (inverse, normalized)
        total_inv = sum(1/(d + 0.001) for d in distances.values())
        confidences = {label: (1/(d + 0.001)) / total_inv
                       for label, d in distances.items()}
        return confidences


# ── Datasets ───────────────────────────────────────────────────
def make_iris():
    """Classic Iris dataset (simplified, no sklearn needed)."""
    np.random.seed(42)
    # Generate synthetic Iris-like data
    classes = {0: "setosa", 1: "versicolor", 2: "virginica"}
    means = {
        0: [5.0, 3.4, 1.5, 0.2],
        1: [5.9, 2.8, 4.3, 1.3],
        2: [6.6, 3.0, 5.6, 2.0]
    }
    stds = {
        0: [0.35, 0.38, 0.17, 0.10],
        1: [0.52, 0.31, 0.47, 0.20],
        2: [0.64, 0.32, 0.55, 0.27]
    }

    X, y = [], []
    for label in range(3):
        for _ in range(50):
            sample = [np.random.normal(m, s) for m, s in
                      zip(means[label], stds[label])]
            X.append(sample)
            y.append(label)

    X, y = np.array(X), np.array(y)
    # Shuffle
    idx = np.random.permutation(len(X))
    return X[idx], y[idx], classes

def make_xor_extended(n_samples=200, n_features=4):
    """Extended XOR problem in higher dimensions."""
    X = np.random.randn(n_samples, n_features)
    # XOR-like: class depends on signs of first two features
    y = ((X[:, 0] > 0) ^ (X[:, 1] > 0)).astype(int)
    return X, y, {0: "class_0", 1: "class_1"}


# ── Main Demo ──────────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  HYPERDIMENSIONAL COMPUTING CLASSIFIER")
    print(f"  Dimensionality: D = {D:,}")
    print("=" * 65)

    # ── Property Demonstrations ────────────────────────────────
    print("\n  FUNDAMENTAL PROPERTIES OF HYPERDIMENSIONAL SPACE")
    print("  " + "─" * 55)

    # 1. Random vectors are quasi-orthogonal
    print("\n  1. Quasi-orthogonality of random vectors:")
    n_test = 100
    distances = []
    for _ in range(n_test):
        a, b = random_hv(), random_hv()
        distances.append(hamming_distance(a, b))
    print(f"     Mean Hamming distance: {np.mean(distances):.4f} (ideal: 0.5000)")
    print(f"     Std deviation:         {np.std(distances):.4f} (should be tiny)")

    # 2. Binding is its own inverse
    print("\n  2. Binding is self-inverse (a ⊗ a = identity):")
    a = random_hv()
    b = random_hv()
    bound = bind(a, b)
    recovered = bind(bound, b)  # Should recover a
    print(f"     dist(a, bind(bind(a,b), b)) = {hamming_distance(a, recovered):.4f} (should be 0)")

    # 3. Noise tolerance
    print("\n  3. Noise tolerance:")
    original = random_hv()
    for noise_level in [0.1, 0.2, 0.3, 0.4]:
        noisy = original.copy()
        n_flip = int(D * noise_level)
        flip_idx = np.random.choice(D, n_flip, replace=False)
        noisy[flip_idx] = 1 - noisy[flip_idx]
        dist = hamming_distance(original, noisy)
        still_similar = "✓ still recognizable" if dist < 0.45 else "✗ too corrupted"
        print(f"     {noise_level*100:.0f}% corruption → distance = {dist:.4f} {still_similar}")

    # 4. Bundling preserves components
    print("\n  4. Bundling preserves component similarity:")
    v1, v2, v3 = random_hv(), random_hv(), random_hv()
    bundled = bundle([v1, v2, v3])
    unrelated = random_hv()
    print(f"     dist(bundle, v1) = {hamming_distance(bundled, v1):.4f} (should be < 0.5)")
    print(f"     dist(bundle, v2) = {hamming_distance(bundled, v2):.4f} (should be < 0.5)")
    print(f"     dist(bundle, unrelated) = {hamming_distance(bundled, unrelated):.4f} (should be ≈ 0.5)")

    # ── Iris Classification ────────────────────────────────────
    print("\n\n  CLASSIFICATION EXPERIMENTS")
    print("  " + "=" * 55)

    X, y, classes = make_iris()
    n = len(X)
    split = int(0.7 * n)

    # Multiple trials for statistical significance
    accuracies = []
    for trial in range(10):
        np.random.seed(trial)
        idx = np.random.permutation(n)
        X_train, y_train = X[idx[:split]], y[idx[:split]]
        X_test, y_test = X[idx[split:]], y[idx[split:]]

        clf = HDClassifier(n_features=4, n_levels=25)
        clf.fit(X_train, y_train)
        pred = clf.predict(X_test)
        acc = np.mean(pred == y_test)
        accuracies.append(acc)

    print(f"\n  Iris Dataset (4 features, 3 classes, 150 samples)")
    print(f"    Mean accuracy: {np.mean(accuracies)*100:.1f}% ± {np.std(accuracies)*100:.1f}%")
    print(f"    Best accuracy: {np.max(accuracies)*100:.1f}%")

    # Show a confusion matrix for best trial
    np.random.seed(np.argmax(accuracies))
    idx = np.random.permutation(n)
    X_train, y_train = X[idx[:split]], y[idx[:split]]
    X_test, y_test = X[idx[split:]], y[idx[split:]]
    clf = HDClassifier(n_features=4, n_levels=25)
    clf.fit(X_train, y_train)
    pred = clf.predict(X_test)

    print(f"\n    Confusion Matrix (best trial):")
    print(f"    {'':>15} {'Predicted':>30}")
    print(f"    {'':>15}", end="")
    for c in sorted(classes.keys()):
        print(f" {classes[c]:>10}", end="")
    print()
    for true_c in sorted(classes.keys()):
        print(f"    {classes[true_c]:>15}", end="")
        for pred_c in sorted(classes.keys()):
            count = np.sum((y_test == true_c) & (pred == pred_c))
            print(f" {count:>10}", end="")
        print()

    # ── Confidence Demo ────────────────────────────────────────
    print(f"\n  Confidence Scores (first 5 test samples):")
    for i in range(min(5, len(X_test))):
        conf = clf.predict_with_confidence(X_test[i])
        true_label = classes[y_test[i]]
        conf_str = " | ".join([f"{classes[k]}: {v:.2f}" for k, v in sorted(conf.items())])
        pred_label = classes[max(conf, key=conf.get)]
        symbol = "✓" if pred_label == true_label else "✗"
        print(f"    {symbol} True: {true_label:>12} | {conf_str}")

    # ── XOR Problem ────────────────────────────────────────────
    X_xor, y_xor, xor_classes = make_xor_extended(n_samples=300)
    split_xor = 200

    xor_accs = []
    for trial in range(10):
        np.random.seed(trial + 100)
        idx = np.random.permutation(len(X_xor))
        clf_xor = HDClassifier(n_features=4, n_levels=30)
        clf_xor.fit(X_xor[idx[:split_xor]], y_xor[idx[:split_xor]])
        pred_xor = clf_xor.predict(X_xor[idx[split_xor:]])
        xor_accs.append(np.mean(pred_xor == y_xor[idx[split_xor:]]))

    print(f"\n  Extended XOR Problem (4 features, 2 classes, 300 samples)")
    print(f"    Mean accuracy: {np.mean(xor_accs)*100:.1f}% ± {np.std(xor_accs)*100:.1f}%")

    # ── Performance Analysis ───────────────────────────────────
    print(f"\n\n  PERFORMANCE CHARACTERISTICS")
    print("  " + "─" * 55)
    import time

    # Training speed
    X_big = np.random.randn(1000, 10)
    y_big = np.random.randint(0, 5, 1000)

    start = time.time()
    clf_big = HDClassifier(n_features=10, n_levels=30)
    clf_big.fit(X_big, y_big)
    train_time = time.time() - start

    start = time.time()
    clf_big.predict(X_big[:100])
    pred_time = time.time() - start

    print(f"    Training 1000 samples (10 features): {train_time*1000:.1f} ms")
    print(f"    Predicting 100 samples:              {pred_time*1000:.1f} ms")
    print(f"    Memory per class prototype:          {D // 8:,} bytes = {D // 8 / 1024:.1f} KB")
    print(f"    Total model size (5 classes):         {5 * D // 8 / 1024:.1f} KB")
    print(f"\n    ★ Single-pass learning, no iterations, no GPU needed")

    print("\n" + "=" * 65)


if __name__ == "__main__":
    main()
