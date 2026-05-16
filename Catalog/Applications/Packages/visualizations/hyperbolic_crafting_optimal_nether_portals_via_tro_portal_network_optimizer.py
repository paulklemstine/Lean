#!/usr/bin/env python3
"""
applications.py — Real-world applications of tropical metric compression
and portal network optimization theory.

Demonstrates how the mathematical framework applies to:
1. Logistics and transportation network design
2. Communication network overlay routing
3. Multi-modal transit optimization
4. Data center interconnection
"""

import random
from algorithms import (
    l1_dist, nether_map, dual_world_cost, prim_mst,
    floyd_warshall_tropical, PortalNetworkOptimizer
)

# ============================================================
# Application 1: Logistics Hub Optimization
# ============================================================
def logistics_demo():
    """
    Model a logistics network where:
    - Surface roads = Overworld (slow, cheap per km)
    - Express highway/rail = Nether (8x faster, fixed access cost)

    The theory predicts that the optimal hub network follows the MST
    of the compressed metric, and there's a crossover distance
    beyond which the express network always dominates.
    """
    print("=" * 60)
    print("APPLICATION 1: Logistics Hub Network Design")
    print("=" * 60)

    # Warehouse locations (in km, scaled by 10)
    warehouses = [
        (0, 0),       # Main distribution center
        (150, 0),     # Port facility
        (0, 120),     # Northern warehouse
        (150, 120),   # Airport cargo
        (75, 60),     # Central sorting hub
        (200, 200),   # Rural distribution point
    ]
    names = ["Main DC", "Port", "North WH", "Airport", "Central Hub", "Rural DP"]

    # Highway ramp cost = 30 units (fixed cost to enter/exit express network)
    ramp_cost = 30

    opt = PortalNetworkOptimizer(warehouses, portal_cost=ramp_cost)
    opt.compute_mst()
    opt.compute_shortest_paths()

    print(f"\nWarehouse locations:")
    for i, (name, loc) in enumerate(zip(names, warehouses)):
        print(f"  [{i}] {name}: {loc}")

    print(f"\nExpress network speed advantage: 8×")
    print(f"Ramp access cost: {ramp_cost} units")
    print(f"Crossover distance: {opt.threshold_distance():.0f} km")

    print(f"\nOptimal backbone connections:")
    for u, v in opt.mst_edges:
        print(f"  {names[u]} ↔ {names[v]}  (cost: {opt.dual_cost_matrix[u][v]})")

    savings = opt.savings_report()
    print(f"\nMST total: {savings['mst_cost']}")
    print(f"Best hub-spoke: {savings['best_star_cost']} (hub: {names[savings['best_star_hub']]})")
    print(f"MST saves: {savings['savings_pct']:.1f}%")


# ============================================================
# Application 2: CDN / Overlay Network Routing
# ============================================================
def cdn_demo():
    """
    Content Delivery Network model:
    - Direct internet = Overworld (variable latency)
    - Private backbone = Nether (low latency, peering cost)

    The tropical closure gives optimal all-pairs routing through
    the overlay network.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: CDN Overlay Network Routing")
    print("=" * 60)

    # Data centers (abstract coordinates representing network distance)
    datacenters = [
        (0, 0),       # US-East
        (400, 0),     # US-West
        (200, 300),   # EU-Central
        (500, 400),   # Asia-Pacific
        (100, 150),   # US-Central
    ]
    dc_names = ["US-East", "US-West", "EU-Central", "Asia-Pac", "US-Central"]

    # Peering cost (ms equivalent)
    peering_cost = 15

    opt = PortalNetworkOptimizer(datacenters, portal_cost=peering_cost)
    opt.compute_mst()
    sp = opt.compute_shortest_paths()

    print(f"\nData centers:")
    for i, name in enumerate(dc_names):
        print(f"  [{i}] {name}")

    print(f"\nDirect internet latency matrix:")
    for i in range(len(datacenters)):
        row = [f"{opt.ow_dist_matrix[i][j]:>5}" for j in range(len(datacenters))]
        print(f"  {dc_names[i]:>12}: " + " ".join(row))

    print(f"\nOptimal overlay routing (via tropical closure):")
    for i in range(len(datacenters)):
        row = [f"{int(sp[i][j]):>5}" for j in range(len(datacenters))]
        print(f"  {dc_names[i]:>12}: " + " ".join(row))

    # Show improvement
    print(f"\nLatency improvement (direct vs overlay):")
    for i in range(len(datacenters)):
        for j in range(i+1, len(datacenters)):
            direct = opt.ow_dist_matrix[i][j]
            overlay = int(sp[i][j])
            if overlay < direct:
                pct = 100 * (direct - overlay) / direct
                print(f"  {dc_names[i]} → {dc_names[j]}: "
                      f"{direct} → {overlay} ({pct:.0f}% faster)")


# ============================================================
# Application 3: Multi-Modal Transit
# ============================================================
def transit_demo():
    """
    Urban transit model:
    - Walking/bus = Overworld (slow, ubiquitous)
    - Subway = Nether (fast, station access cost)

    Shows how the portal cost threshold determines which trips
    benefit from subway access.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Multi-Modal Urban Transit")
    print("=" * 60)

    # Locations in city blocks
    locations = [
        (0, 0),       # Downtown
        (40, 0),      # Business district
        (0, 48),      # University
        (40, 48),     # Hospital
        (80, 24),     # Airport
        (20, 24),     # Central park
    ]
    loc_names = ["Downtown", "Business", "University", "Hospital", "Airport", "Central Pk"]

    # Station access time = 5 minutes walking
    station_cost = 5

    print(f"Station access time: {station_cost} min each way")
    threshold = (16 * station_cost) / 7
    print(f"Subway worthwhile for trips > {threshold:.0f} blocks")

    print(f"\nTrip analysis:")
    print(f"{'From':>12} → {'To':<12} {'Walk':>5} {'Subway':>7} {'Best':>5} {'Mode':<8}")
    print("-" * 60)

    for i in range(len(locations)):
        for j in range(i+1, len(locations)):
            walk = l1_dist(locations[i], locations[j])
            subway = dual_world_cost(locations[i], locations[j], station_cost)
            mode = "Subway" if subway < walk else "Walk"
            best = min(walk, subway)
            print(f"{loc_names[i]:>12} → {loc_names[j]:<12} {walk:>5} {subway:>7} {best:>5} {mode:<8}")


# ============================================================
# Application 4: Phase Transition Analysis
# ============================================================
def phase_transition_demo():
    """
    Analyze how the portal cost parameter creates a phase transition
    in optimal network structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Portal Cost Phase Transition")
    print("=" * 60)

    settlements = [
        (0, 0), (100, 0), (0, 100), (100, 100),
        (50, 50), (150, 50), (50, 150), (200, 200),
    ]
    n = len(settlements)

    print(f"\n{'Portal Cost':>12} {'MST Cost':>10} {'Star Cost':>10} {'Savings %':>10} {'Threshold':>10}")
    print("-" * 55)

    for c in [0, 5, 10, 20, 50, 100, 200, 500]:
        opt = PortalNetworkOptimizer(settlements, portal_cost=c)
        opt.compute_mst()
        sr = opt.savings_report()
        thresh = opt.threshold_distance()
        print(f"{c:>12} {sr['mst_cost']:>10.0f} {sr['best_star_cost']:>10.0f} "
              f"{sr['savings_pct']:>9.1f}% {thresh:>10.0f}")


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    logistics_demo()
    cdn_demo()
    transit_demo()
    phase_transition_demo()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)
