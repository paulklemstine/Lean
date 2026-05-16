"""
Applications of Tree Metric Reconstruction

Demonstrates real-world applications in:
1. Phylogenetic tree reconstruction from sequence data
2. Network tomography (inferring network topology from delays)
3. Hierarchical clustering validation
"""

import numpy as np
from algorithms import (
    is_finite_metric, four_point_condition, reconstruct_tree,
    tree_distance_matrix, verify_reconstruction, pendant_length
)


def phylogenetic_reconstruction():
    """Application: Reconstructing evolutionary trees from molecular data.
    
    Given pairwise evolutionary distances between species (computed from
    DNA/protein sequence alignment), reconstruct the phylogenetic tree.
    """
    print("=" * 60)
    print("APPLICATION 1: Phylogenetic Tree Reconstruction")
    print("=" * 60)
    
    # Simulated distances (substitutions per site × 1000) between primates
    species = ["Human", "Chimpanzee", "Gorilla", "Orangutan", "Macaque"]
    D = np.array([
        [  0, 13, 18, 35, 55],
        [ 13,  0, 19, 36, 56],
        [ 18, 19,  0, 35, 55],
        [ 35, 36, 35,  0, 58],
        [ 55, 56, 55, 58,  0]
    ], dtype=float)
    
    print(f"\nSpecies: {species}")
    print(f"Metric valid: {is_finite_metric(D)}")
    print(f"Tree-like (four-point): {four_point_condition(D)}")
    
    if four_point_condition(D):
        tree = reconstruct_tree(D)
        print(f"Reconstructed tree: {tree.to_newick()}")
        print(f"Verification: {verify_reconstruction(D, tree)}")
        
        # Interpret pendant lengths
        print("\nPendant edge lengths (evolutionary distances to nearest common ancestor):")
        for i in range(len(species)):
            others = [j for j in range(len(species)) if j != i]
            pl = min(pendant_length(D, i, j, k) for j in others for k in others if j != k)
            print(f"  {species[i]}: {pl:.1f} substitutions/1000 sites")
    else:
        print("Warning: Distances are not exactly tree-like.")
        print("In practice, use neighbor-joining or other approximate methods.")


def network_tomography():
    """Application: Inferring network topology from pairwise delays.
    
    Given measured round-trip times between border routers,
    reconstruct the internal network topology.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Tomography")
    print("=" * 60)
    
    routers = ["NYC", "LAX", "CHI", "MIA", "SEA", "DEN"]
    
    # Delay matrix (milliseconds) - designed to be tree-like
    D = np.array([
        [ 0, 40, 15, 20, 45, 30],
        [40,  0, 35, 40, 15, 20],
        [15, 35,  0, 25, 40, 25],
        [20, 40, 25,  0, 45, 30],
        [45, 15, 40, 45,  0, 25],
        [30, 20, 25, 30, 25,  0]
    ], dtype=float)
    
    print(f"\nBorder routers: {routers}")
    print(f"Metric valid: {is_finite_metric(D)}")
    print(f"Tree-like topology: {four_point_condition(D)}")
    
    if four_point_condition(D):
        tree = reconstruct_tree(D)
        print(f"\nReconstructed network tree: {tree.to_newick()}")
        print(f"Internal nodes (hidden switches/routers): {tree.num_vertices() - len(routers)}")
        print(f"Verification: {verify_reconstruction(D, tree)}")
    else:
        print("Network topology is not tree-like (contains cycles/redundancy).")
        # Compute four-point violation magnitude
        n = D.shape[0]
        max_violation = 0
        for i in range(n):
            for j in range(i+1, n):
                for k in range(j+1, n):
                    for l in range(k+1, n):
                        sums = sorted([D[i,j]+D[k,l], D[i,k]+D[j,l], D[i,l]+D[j,k]])
                        violation = abs(sums[1] - sums[2])
                        max_violation = max(max_violation, violation)
        print(f"Maximum four-point violation: {max_violation:.1f} ms")
        print("This quantifies how far the network is from being tree-like.")


def hierarchical_clustering_validation():
    """Application: Validating hierarchical clustering results.
    
    Check whether a given distance matrix admits an exact ultrametric
    (special case of tree metric) or tree representation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Hierarchical Clustering Validation")
    print("=" * 60)
    
    items = ["Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig"]
    
    # Feature-based distances
    D = np.array([
        [0, 3, 5, 7, 8, 6],
        [3, 0, 4, 8, 9, 7],
        [5, 4, 0, 6, 7, 5],
        [7, 8, 6, 0, 3, 5],
        [8, 9, 7, 3, 0, 4],
        [6, 7, 5, 5, 4, 0]
    ], dtype=float)
    
    print(f"\nItems: {items}")
    print(f"Distance matrix:\n{D}")
    print(f"Valid metric: {is_finite_metric(D)}")
    print(f"Admits exact tree: {four_point_condition(D)}")
    
    if four_point_condition(D):
        tree = reconstruct_tree(D)
        print(f"\nExact hierarchical tree: {tree.to_newick()}")
        print("→ Hierarchical clustering is EXACT for this data.")
    else:
        # Find closest tree metric
        print("→ No exact tree representation exists.")
        n = D.shape[0]
        violations = 0
        total = 0
        for i in range(n):
            for j in range(i+1, n):
                for k in range(j+1, n):
                    for l in range(k+1, n):
                        sums = sorted([D[i,j]+D[k,l], D[i,k]+D[j,l], D[i,l]+D[j,k]])
                        total += 1
                        if abs(sums[1] - sums[2]) > 1e-10:
                            violations += 1
        print(f"  {violations}/{total} quadruples violate four-point condition")
        print("  Hierarchical clustering will introduce distortion.")


if __name__ == "__main__":
    phylogenetic_reconstruction()
    network_tomography()
    hierarchical_clustering_validation()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


"""
Tree Metric Reconstruction: Demonstrations and Visualizations

Demonstrates the Buneman reconstruction algorithm on various examples,
including phylogenetic trees, network tomography, and random metrics.
Generates visualizations saved as PNG files.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from algorithms import (
    is_finite_metric, four_point_condition, pendant_length,
    reconstruct_tree, tree_distance_matrix, verify_reconstruction,
    find_cherry_pair, TreeNode
)


def demo_tripod():
    """Demonstrate the tripod (3-point) realization."""
    print("=" * 60)
    print("DEMO 1: Tripod Realization (3 points)")
    print("=" * 60)
    
    D = np.array([
        [0, 5, 7],
        [5, 0, 8],
        [7, 8, 0]
    ], dtype=float)
    
    print(f"\nDistance matrix:\n{D}")
    print(f"\nPendant lengths:")
    for i in range(3):
        j, k = [x for x in range(3) if x != i]
        pl = pendant_length(D, i, j, k)
        print(f"  w_{i} = (D[{i},{j}] + D[{i},{k}] - D[{j},{k}]) / 2 = {pl:.1f}")
    
    tree = reconstruct_tree(D)
    print(f"\nTree (Newick): {tree.to_newick()}")
    print(f"Verification: {verify_reconstruction(D, tree)}")
    return D, tree


def demo_five_point():
    """Demonstrate reconstruction on a 5-point tree metric."""
    print("\n" + "=" * 60)
    print("DEMO 2: Five-Point Reconstruction")
    print("=" * 60)
    
    D = np.array([
        [0, 5, 6, 8, 7],
        [5, 0, 7, 9, 8],
        [6, 7, 0, 4, 3],
        [8, 9, 4, 0, 3],
        [7, 8, 3, 3, 0]
    ], dtype=float)
    
    print(f"\nDistance matrix:\n{D}")
    print(f"Four-point condition: {four_point_condition(D)}")
    
    ci, cj = find_cherry_pair(D)
    print(f"Cherry pair found: ({ci}, {cj})")
    
    tree = reconstruct_tree(D)
    print(f"Tree (Newick): {tree.to_newick()}")
    print(f"Vertices: {tree.num_vertices()}, Leaves: {len(tree.leaves())}")
    print(f"Verification: {verify_reconstruction(D, tree)}")
    return D, tree


def demo_phylogenetic():
    """Demonstrate phylogenetic tree reconstruction."""
    print("\n" + "=" * 60)
    print("DEMO 3: Phylogenetic Tree Reconstruction")
    print("=" * 60)
    
    # Simulated evolutionary distances (in substitutions per site × 100)
    species = ["Human", "Chimp", "Gorilla", "Orangutan", "Gibbon", "Macaque"]
    n = len(species)
    
    # Tree: ((Human:1, Chimp:1):2, Gorilla:3):1, (Orangutan:4, (Gibbon:5, Macaque:6):1):2)
    D = np.array([
        [ 0,  2,  4,  8, 10, 11],
        [ 2,  0,  4,  8, 10, 11],
        [ 4,  4,  0,  8, 10, 11],
        [ 8,  8,  8,  0, 10, 11],
        [10, 10, 10, 10,  0, 12],
        [11, 11, 11, 11, 12,  0]
    ], dtype=float)
    
    print(f"\nSpecies: {species}")
    print(f"Distance matrix:\n{D}")
    print(f"Four-point condition: {four_point_condition(D)}")
    
    tree = reconstruct_tree(D, labels=list(range(n)))
    print(f"Tree (Newick): {tree.to_newick()}")
    print(f"Verification: {verify_reconstruction(D, tree)}")
    return D, tree, species


def demo_non_tree_metric():
    """Show what happens with a non-tree metric."""
    print("\n" + "=" * 60)
    print("DEMO 4: Non-Tree Metric Detection")
    print("=" * 60)
    
    # Square metric (not a tree metric)
    D = np.array([
        [0, 1, 2, 1],
        [1, 0, 1, 2],
        [2, 1, 0, 1],
        [1, 2, 1, 0]
    ], dtype=float)
    
    print(f"\nSquare distance matrix:\n{D}")
    print(f"Is metric: {is_finite_metric(D)}")
    print(f"Four-point condition: {four_point_condition(D)}")
    
    # Check specific violation
    sums = [
        D[0,1] + D[2,3],
        D[0,2] + D[1,3],
        D[0,3] + D[1,2]
    ]
    print(f"For (0,1,2,3): sums = {sums}")
    print(f"  Two largest equal? {abs(sorted(sums)[1] - sorted(sums)[2]) < 1e-10}")


def demo_random_tree():
    """Generate a random tree and verify reconstruction."""
    print("\n" + "=" * 60)
    print("DEMO 5: Random Tree Generation and Reconstruction")
    print("=" * 60)
    
    np.random.seed(42)
    n = 8
    
    # Build a random tree by successive attachment
    root = TreeNode()
    leaf0 = TreeNode(label=0)
    leaf1 = TreeNode(label=1)
    w = np.random.exponential(2.0)
    root.add_child(w, leaf0)
    root.add_child(w, leaf1)
    
    all_nodes = [root, leaf0, leaf1]
    
    for i in range(2, n):
        # Pick a random edge and insert a new internal node
        edge_nodes = [(parent, child, w) 
                      for parent in all_nodes 
                      for w, child in parent.children]
        
        if edge_nodes:
            parent, child, old_w = edge_nodes[np.random.randint(len(edge_nodes))]
            
            # Split edge: parent --(old_w)--> child becomes
            # parent --(split)--> new_internal --(old_w - split)--> child
            #                                  \--(new_w)--> new_leaf
            split = np.random.uniform(0, old_w)
            new_internal = TreeNode()
            new_leaf = TreeNode(label=i)
            new_w = np.random.exponential(2.0)
            
            # Remove old child from parent
            parent.children = [(w, c) for w, c in parent.children if c is not child]
            parent.add_child(split, new_internal)
            new_internal.add_child(old_w - split, child)
            child.parent = new_internal
            child.parent_weight = old_w - split
            new_internal.add_child(new_w, new_leaf)
            
            all_nodes.extend([new_internal, new_leaf])
    
    # Extract distances
    D = tree_distance_matrix(root, n)
    print(f"\nGenerated {n}-leaf random tree")
    print(f"Distance matrix:\n{np.round(D, 2)}")
    print(f"Four-point condition: {four_point_condition(D)}")
    
    # Reconstruct
    tree_recon = reconstruct_tree(D)
    D_recon = tree_distance_matrix(tree_recon, n)
    max_err = np.max(np.abs(D - D_recon))
    print(f"Reconstruction error: {max_err:.2e}")
    print(f"Correct: {max_err < 1e-8}")
    return D, root, tree_recon


def create_visualization(D, title, filename):
    """Create a distance matrix heatmap visualization."""
    fig, ax = plt.subplots(1, 1, figsize=(6, 5))
    im = ax.imshow(D, cmap='YlOrRd', interpolation='nearest')
    ax.set_title(title, fontsize=14)
    ax.set_xlabel('Vertex')
    ax.set_ylabel('Vertex')
    
    n = D.shape[0]
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{D[i,j]:.1f}', ha='center', va='center', fontsize=8)
    
    plt.colorbar(im, ax=ax, label='Distance')
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: {filename}")


def create_four_point_check_viz(D, filename):
    """Visualize the four-point condition check."""
    n = D.shape[0]
    violations = []
    satisfactions = []
    
    for i in range(n):
        for j in range(i+1, n):
            for k in range(j+1, n):
                for l in range(k+1, n):
                    sums = sorted([
                        D[i,j]+D[k,l], D[i,k]+D[j,l], D[i,l]+D[j,k]
                    ])
                    gap = abs(sums[1] - sums[2])
                    if gap > 1e-10:
                        violations.append(((i,j,k,l), gap))
                    else:
                        satisfactions.append(((i,j,k,l), sums[0], sums[1]))
    
    fig, ax = plt.subplots(figsize=(8, 5))
    
    if satisfactions:
        mins = [s[1] for s in satisfactions]
        maxs = [s[2] for s in satisfactions]
        x = range(len(satisfactions))
        ax.bar(x, maxs, color='steelblue', alpha=0.7, label='Two largest (equal)')
        ax.bar(x, mins, color='coral', alpha=0.7, label='Smallest')
        ax.set_xlabel('Quadruple index')
        ax.set_ylabel('Sum value')
        ax.set_title('Four-Point Condition: Distance Sum Triples')
        ax.legend()
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: {filename}")


def create_reconstruction_comparison(D_orig, D_recon, filename):
    """Compare original and reconstructed distance matrices."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    n = D_orig.shape[0]
    
    im0 = axes[0].imshow(D_orig, cmap='YlOrRd')
    axes[0].set_title('Original Distances')
    plt.colorbar(im0, ax=axes[0])
    
    im1 = axes[1].imshow(D_recon, cmap='YlOrRd')
    axes[1].set_title('Reconstructed Distances')
    plt.colorbar(im1, ax=axes[1])
    
    diff = np.abs(D_orig - D_recon)
    im2 = axes[2].imshow(diff, cmap='Reds')
    axes[2].set_title(f'|Error| (max={np.max(diff):.1e})')
    plt.colorbar(im2, ax=axes[2])
    
    for ax in axes:
        ax.set_xlabel('Vertex')
        ax.set_ylabel('Vertex')
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: {filename}")


def create_complexity_plot(filename):
    """Plot reconstruction complexity empirically."""
    sizes = [4, 6, 8, 10, 15, 20, 30, 40, 50]
    times = []
    
    import time
    
    for n in sizes:
        # Generate random tree metric
        np.random.seed(n)
        root = TreeNode()
        root.add_child(1.0, TreeNode(label=0))
        root.add_child(1.0, TreeNode(label=1))
        nodes = [root]
        
        for i in range(2, n):
            parent = nodes[np.random.randint(len(nodes))]
            if parent.children:
                w, child = parent.children[np.random.randint(len(parent.children))]
                internal = TreeNode()
                parent.children = [(ww, c) if c is not child else (w/2, internal) 
                                   for ww, c in parent.children]
                internal.parent = parent
                internal.parent_weight = w/2
                internal.add_child(w/2, child)
                child.parent = internal
                child.parent_weight = w/2
                internal.add_child(np.random.exponential(1.0), TreeNode(label=i))
                nodes.append(internal)
            else:
                parent.add_child(np.random.exponential(1.0), TreeNode(label=i))
        
        D = tree_distance_matrix(root, n)
        
        t0 = time.time()
        for _ in range(max(1, 100 // n)):
            reconstruct_tree(D)
        elapsed = (time.time() - t0) / max(1, 100 // n)
        times.append(elapsed)
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.loglog(sizes, times, 'bo-', markersize=8, label='Measured time')
    
    # Fit cubic
    if len(sizes) > 2:
        c = times[-1] / (sizes[-1] ** 3)
        cubic = [c * s**3 for s in sizes]
        ax.loglog(sizes, cubic, 'r--', alpha=0.7, label='O(n³) reference')
    
    ax.set_xlabel('Number of leaves (n)', fontsize=12)
    ax.set_ylabel('Time (seconds)', fontsize=12)
    ax.set_title('Reconstruction Algorithm Complexity', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: {filename}")


if __name__ == "__main__":
    # Run all demos
    D3, tree3 = demo_tripod()
    D5, tree5 = demo_five_point()
    D_phylo, tree_phylo, species = demo_phylogenetic()
    demo_non_tree_metric()
    D_rand, root_rand, tree_rand = demo_random_tree()
    
    # Create visualizations
    print("\n" + "=" * 60)
    print("Creating visualizations...")
    print("=" * 60)
    
    create_visualization(D3, "3-Point Metric (Tripod)", "viz_tripod.png")
    create_visualization(D5, "5-Point Tree Metric", "viz_five_point.png")
    create_visualization(D_phylo, "Primate Evolutionary Distances", "viz_phylogenetic.png")
    create_four_point_check_viz(D5, "viz_four_point.png")
    
    D5_recon = tree_distance_matrix(tree5, 5)
    create_reconstruction_comparison(D5, D5_recon, "viz_reconstruction.png")
    
    create_complexity_plot("viz_complexity.png")
    
    print("\nAll demos complete!")
