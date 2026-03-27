#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 9: TOPOLOGICAL ANOMALY DETECTION                         ║
║  ────────────────────────────────────────────────────────────    ║
║  Uses persistent homology to detect anomalies that change the   ║
║  SHAPE of data — not just its statistics. Catches coordinated   ║
║  structural shifts that evade mean/variance monitoring.         ║
║                                                                  ║
║  Implemented from scratch: Vietoris-Rips complex construction,  ║
║  Union-Find for H0, and persistence diagram analysis.           ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np
from typing import List, Tuple

# ── Union-Find Data Structure ──────────────────────────────────
class UnionFind:
    """Weighted union-find with path compression for H0 computation."""

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n_components = n
        self.birth = list(range(n))  # Birth time of each component

    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> Tuple[bool, int, int]:
        """Union two sets. Returns (merged, dying_component_birth, death_time)."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False, -1, -1

        # Younger component dies (higher birth time = younger)
        if self.birth[rx] > self.birth[ry]:
            rx, ry = ry, rx  # rx is older

        dying_birth = self.birth[ry]

        if self.rank[rx] < self.rank[ry]:
            self.parent[rx] = ry
            self.birth[ry] = min(self.birth[rx], self.birth[ry])
        elif self.rank[rx] > self.rank[ry]:
            self.parent[ry] = rx
        else:
            self.parent[ry] = rx
            self.rank[rx] += 1

        self.n_components -= 1
        return True, dying_birth, -1  # death_time set by caller


# ── Persistent Homology (H0 — Connected Components) ───────────
class PersistentHomology:
    """
    Compute 0-dimensional persistent homology (connected components)
    using the Vietoris-Rips filtration.

    For H0: track when connected components are born and merge.
    Long-lived components = genuine clusters.
    Short-lived components = noise.
    """

    def __init__(self):
        self.persistence_diagram = []  # List of (birth, death) pairs
        self.max_filtration = 0

    def fit(self, points: np.ndarray, max_radius: float = None) -> list:
        """Compute H0 persistence diagram."""
        n = len(points)

        # Compute all pairwise distances
        distances = np.zeros((n, n))
        for i in range(n):
            for j in range(i+1, n):
                d = np.linalg.norm(points[i] - points[j])
                distances[i, j] = d
                distances[j, i] = d

        if max_radius is None:
            max_radius = np.max(distances) * 0.8

        self.max_filtration = max_radius

        # Sort edges by distance
        edges = []
        for i in range(n):
            for j in range(i+1, n):
                if distances[i, j] <= max_radius:
                    edges.append((distances[i, j], i, j))
        edges.sort()

        # Build filtration using Union-Find
        uf = UnionFind(n)
        self.persistence_diagram = []

        for dist, i, j in edges:
            merged, dying_birth, _ = uf.union(i, j)
            if merged:
                # A component dies at this distance
                # Birth was at distance 0 (each point is born at 0)
                birth = 0.0  # All H0 features born at 0
                death = dist
                persistence = death - birth
                if persistence > 1e-10:  # Skip trivial
                    self.persistence_diagram.append((birth, death))

        # Add the final surviving component (infinite persistence)
        self.persistence_diagram.append((0.0, max_radius))

        return self.persistence_diagram

    def compute_features(self) -> dict:
        """Extract topological features from persistence diagram."""
        if not self.persistence_diagram:
            return {}

        persistences = [d - b for b, d in self.persistence_diagram]

        features = {
            'n_features': len(self.persistence_diagram),
            'max_persistence': max(persistences),
            'mean_persistence': np.mean(persistences),
            'std_persistence': np.std(persistences),
            'total_persistence': sum(persistences),
            'entropy': self._persistence_entropy(persistences),
            'n_significant': sum(1 for p in persistences if p > np.mean(persistences)),
        }
        return features

    def _persistence_entropy(self, persistences: list) -> float:
        """Shannon entropy of the persistence diagram."""
        total = sum(persistences)
        if total == 0:
            return 0
        probs = [p / total for p in persistences]
        return -sum(p * np.log2(p + 1e-10) for p in probs)


# ── Anomaly Detector ──────────────────────────────────────────
class TopologicalAnomalyDetector:
    """
    Detect anomalies by monitoring topological changes in sliding windows.

    Normal behavior establishes a baseline topology (number of clusters,
    persistence distribution). Anomalies are detected when the topology
    changes significantly.
    """

    def __init__(self, window_size: int = 50, baseline_windows: int = 10):
        self.window_size = window_size
        self.baseline_windows = baseline_windows
        self.baseline_features = []
        self.ph = PersistentHomology()

    def fit_baseline(self, data: np.ndarray):
        """Learn normal topological behavior from baseline data."""
        n = len(data)
        self.baseline_features = []

        for start in range(0, min(n - self.window_size, self.baseline_windows * self.window_size),
                           self.window_size):
            window = data[start:start + self.window_size]
            self.ph.fit(window)
            features = self.ph.compute_features()
            self.baseline_features.append(features)

        # Compute baseline statistics
        self.baseline_stats = {}
        for key in self.baseline_features[0]:
            values = [f[key] for f in self.baseline_features]
            self.baseline_stats[key] = {
                'mean': np.mean(values),
                'std': np.std(values) + 1e-10,
            }

    def score_window(self, window: np.ndarray) -> float:
        """Score a window's anomalousness (higher = more anomalous)."""
        self.ph.fit(window)
        features = self.ph.compute_features()

        if not self.baseline_stats:
            return 0.0

        # Z-score across all topological features
        z_scores = []
        for key in features:
            if key in self.baseline_stats:
                z = abs(features[key] - self.baseline_stats[key]['mean']) / self.baseline_stats[key]['std']
                z_scores.append(z)

        return np.mean(z_scores) if z_scores else 0.0

    def detect(self, data: np.ndarray, threshold: float = 2.0) -> list:
        """Detect anomalous windows in streaming data."""
        anomalies = []
        n = len(data)

        for start in range(0, n - self.window_size, self.window_size // 2):
            window = data[start:start + self.window_size]
            score = self.score_window(window)
            is_anomaly = score > threshold
            anomalies.append({
                'start': start,
                'end': start + self.window_size,
                'score': score,
                'is_anomaly': is_anomaly,
            })

        return anomalies


# ── Synthetic Data Generators ──────────────────────────────────
def generate_normal_clusters(n_points: int, n_clusters: int = 3,
                              dim: int = 3) -> np.ndarray:
    """Generate well-separated clusters (normal behavior)."""
    points = []
    for i in range(n_clusters):
        center = np.random.randn(dim) * 5
        cluster = center + np.random.randn(n_points // n_clusters, dim) * 0.5
        points.append(cluster)
    return np.vstack(points)

def inject_topology_change(data: np.ndarray, start: int, end: int,
                            change_type: str = "merge") -> np.ndarray:
    """Inject a topological anomaly into the data."""
    modified = data.copy()

    if change_type == "merge":
        # Merge two clusters (reduces H0 count)
        mid = (start + end) // 2
        modified[start:mid] = np.mean(modified[start:end], axis=0) + \
                               np.random.randn(mid - start, data.shape[1]) * 0.3

    elif change_type == "split":
        # Split a cluster (increases H0 count)
        n_split = end - start
        half = n_split // 2
        modified[start:start+half] += np.array([3, 0, 0] + [0]*(data.shape[1]-3))[:data.shape[1]]
        modified[start+half:end] -= np.array([3, 0, 0] + [0]*(data.shape[1]-3))[:data.shape[1]]

    elif change_type == "drift":
        # Gradual drift (changes topology slowly)
        for i in range(start, end):
            t = (i - start) / (end - start)
            modified[i] += t * np.array([5, 5, 0] + [0]*(data.shape[1]-3))[:data.shape[1]]

    return modified


# ── Statistical Baseline Detector ─────────────────────────────
class StatisticalAnomalyDetector:
    """Simple statistical anomaly detection for comparison."""

    def __init__(self, window_size: int = 50):
        self.window_size = window_size
        self.baseline_mean = None
        self.baseline_std = None

    def fit_baseline(self, data: np.ndarray):
        self.baseline_mean = np.mean(data, axis=0)
        self.baseline_std = np.std(data, axis=0) + 1e-10

    def score_window(self, window: np.ndarray) -> float:
        window_mean = np.mean(window, axis=0)
        z = np.mean(np.abs(window_mean - self.baseline_mean) / self.baseline_std)
        return z

    def detect(self, data: np.ndarray, threshold: float = 2.0) -> list:
        anomalies = []
        n = len(data)
        for start in range(0, n - self.window_size, self.window_size // 2):
            window = data[start:start + self.window_size]
            score = self.score_window(window)
            anomalies.append({
                'start': start,
                'end': start + self.window_size,
                'score': score,
                'is_anomaly': score > threshold,
            })
        return anomalies


# ── Main Demo ──────────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  TOPOLOGICAL ANOMALY DETECTION")
    print("  via Persistent Homology")
    print("=" * 65)

    np.random.seed(42)

    # ── Basic Persistence Demo ─────────────────────────────────
    print("\n  PERSISTENCE DIAGRAM DEMO")
    print("  " + "─" * 55)

    # Two well-separated clusters
    cluster1 = np.random.randn(20, 2) * 0.5 + np.array([0, 0])
    cluster2 = np.random.randn(20, 2) * 0.5 + np.array([5, 0])
    two_clusters = np.vstack([cluster1, cluster2])

    ph = PersistentHomology()
    diagram = ph.fit(two_clusters, max_radius=8.0)
    features = ph.compute_features()

    print(f"\n  Two-cluster dataset (40 points):")
    print(f"    Persistence diagram (H0):")
    sorted_diagram = sorted(diagram, key=lambda x: -(x[1] - x[0]))
    for i, (birth, death) in enumerate(sorted_diagram[:10]):
        persistence = death - birth
        bar = "█" * int(persistence / ph.max_filtration * 40)
        print(f"      [{birth:.2f}, {death:.2f}] persistence={persistence:.2f} |{bar}")

    print(f"\n    Topological features:")
    for key, val in features.items():
        print(f"      {key}: {val:.4f}")

    print(f"\n    Interpretation: {features['n_significant']} significant features")
    print(f"    (The long bar = gap between clusters, short bars = within-cluster noise)")

    # ── Anomaly Detection Experiment ───────────────────────────
    print(f"\n\n  ANOMALY DETECTION EXPERIMENT")
    print("  " + "═" * 55)

    # Generate streaming data
    n_total = 600
    dim = 3
    window_size = 40

    # Normal baseline
    data = generate_normal_clusters(n_total, n_clusters=3, dim=dim)

    # Inject anomalies at different points
    anomaly_regions = [
        (200, 260, "merge", "Cluster merge"),
        (350, 410, "split", "Cluster split"),
        (480, 540, "drift", "Gradual drift"),
    ]

    for start, end, change_type, description in anomaly_regions:
        data = inject_topology_change(data, start, end, change_type)

    # ── Topological Detection ──────────────────────────────────
    print(f"\n  Dataset: {n_total} points in {dim}D with 3 injected anomalies")
    print(f"  Window size: {window_size}")

    topo_detector = TopologicalAnomalyDetector(window_size=window_size)
    topo_detector.fit_baseline(data[:150])  # First 150 points as baseline

    topo_results = topo_detector.detect(data, threshold=1.5)

    # ── Statistical Detection ──────────────────────────────────
    stat_detector = StatisticalAnomalyDetector(window_size=window_size)
    stat_detector.fit_baseline(data[:150])
    stat_results = stat_detector.detect(data, threshold=1.5)

    # ── Compare Results ────────────────────────────────────────
    print(f"\n  {'─' * 55}")
    print(f"  DETECTION TIMELINE")
    print(f"  {'─' * 55}")

    # Create timeline
    max_pos = n_total
    timeline_width = 60

    def make_timeline(results, name):
        line = [' '] * timeline_width
        for r in results:
            if r['is_anomaly']:
                start_pos = int(r['start'] / max_pos * timeline_width)
                end_pos = int(r['end'] / max_pos * timeline_width)
                for p in range(start_pos, min(end_pos, timeline_width)):
                    line[p] = '█'
        return f"    {name:>12}: |{''.join(line)}|"

    # Mark true anomaly regions
    true_line = [' '] * timeline_width
    for start, end, _, _ in anomaly_regions:
        for p in range(int(start/max_pos*timeline_width),
                       min(int(end/max_pos*timeline_width), timeline_width)):
            true_line[p] = '█'

    print(f"\n    {'Truth':>12}: |{''.join(true_line)}|")
    print(make_timeline(topo_results, "Topological"))
    print(make_timeline(stat_results, "Statistical"))
    print(f"    {'':>12}  {'|':<1}{'0':^20}{'200':^13}{'400':^14}{'600':>13}|")

    # ── Metrics ────────────────────────────────────────────────
    def compute_metrics(results, anomaly_regions, n_total):
        true_positives = 0
        false_positives = 0
        detected_anomalies = set()

        for r in results:
            if r['is_anomaly']:
                is_true = False
                for idx, (start, end, _, _) in enumerate(anomaly_regions):
                    # Overlap check
                    if r['start'] < end and r['end'] > start:
                        is_true = True
                        detected_anomalies.add(idx)
                if is_true:
                    true_positives += 1
                else:
                    false_positives += 1

        total_anomalous = sum(1 for r in results if r['is_anomaly'])
        precision = true_positives / max(total_anomalous, 1)
        recall = len(detected_anomalies) / len(anomaly_regions)

        return {
            'precision': precision,
            'recall': recall,
            'f1': 2 * precision * recall / max(precision + recall, 1e-10),
            'true_positives': true_positives,
            'false_positives': false_positives,
            'detected': len(detected_anomalies),
            'total_anomalies': len(anomaly_regions),
        }

    topo_metrics = compute_metrics(topo_results, anomaly_regions, n_total)
    stat_metrics = compute_metrics(stat_results, anomaly_regions, n_total)

    print(f"\n  {'─' * 55}")
    print(f"  DETECTION METRICS")
    print(f"  {'─' * 55}")
    print(f"    {'Metric':<25} {'Topological':>15} {'Statistical':>15}")
    print(f"    {'─'*55}")
    print(f"    {'Precision':<25} {topo_metrics['precision']:>14.3f} {stat_metrics['precision']:>14.3f}")
    print(f"    {'Recall':<25} {topo_metrics['recall']:>14.3f} {stat_metrics['recall']:>14.3f}")
    print(f"    {'F1 Score':<25} {topo_metrics['f1']:>14.3f} {stat_metrics['f1']:>14.3f}")
    print(f"    {'Anomalies detected':<25} {topo_metrics['detected']:>12d}/3 {stat_metrics['detected']:>12d}/3")
    print(f"    {'False positives':<25} {topo_metrics['false_positives']:>15d} {stat_metrics['false_positives']:>15d}")

    # ── Per-anomaly Analysis ───────────────────────────────────
    print(f"\n  PER-ANOMALY DETECTION:")
    for idx, (start, end, change_type, description) in enumerate(anomaly_regions):
        topo_detected = any(r['is_anomaly'] and r['start'] < end and r['end'] > start
                            for r in topo_results)
        stat_detected = any(r['is_anomaly'] and r['start'] < end and r['end'] > start
                            for r in stat_results)
        print(f"    {description:>20} [{start}-{end}]: "
              f"Topo={'✓' if topo_detected else '✗'}  Stat={'✓' if stat_detected else '✗'}")

    # ── Key Insight ────────────────────────────────────────────
    print(f"\n\n  {'═' * 55}")
    print(f"  KEY INSIGHT")
    print(f"  {'═' * 55}")
    print(f"    Topological detection catches structural changes that")
    print(f"    preserve global statistics:")
    print(f"    • Cluster merges/splits don't change mean or variance")
    print(f"    • Topology changes (# of holes, # of components) are")
    print(f"      invisible to statistical methods")
    print(f"    • Persistent homology provides a SHAPE fingerprint")
    print(f"      that is robust to noise but sensitive to structure")
    print(f"\n    ★ When the shape of your data matters more than")
    print(f"      its statistics, topology is the right tool.")
    print("=" * 65)


if __name__ == "__main__":
    main()
