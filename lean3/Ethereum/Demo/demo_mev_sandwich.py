#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║   MEV SANDWICH ATTACK VISUALIZER                                ║
║   Shows how sandwich attacks extract value from pending trades   ║
║   Formally verified properties in MEV.lean                       ║
╚══════════════════════════════════════════════════════════════════╝
"""

import math

def constant_product_swap(x, y, dx):
    """Returns dy for constant product swap"""
    dy = y * dx / (x + dx)
    return dy

def simulate_sandwich(pool_x, pool_y, victim_amount, front_run_amount, fee=0.003):
    """
    Simulate a sandwich attack:
    1. Front-run: attacker buys before victim
    2. Victim trade: executes at worse price  
    3. Back-run: attacker sells after victim
    
    PROVED: swapOutput is always positive (sandwich_output_pos)
    """
    print(f"\n  ┌{'─'*56}┐")
    print(f"  │{'SANDWICH ATTACK SIMULATION':^56}│")
    print(f"  └{'─'*56}┘")
    
    x, y = pool_x, pool_y
    initial_price = y / x
    
    print(f"\n  Initial Pool: x={x:.0f}, y={y:.0f}")
    print(f"  Initial Price: {initial_price:.4f}")
    print(f"  Victim Trade Size: {victim_amount:.2f}")
    print(f"  Attacker Front-run: {front_run_amount:.2f}")
    
    # ─── Step 0: What victim WOULD get without sandwich ───
    victim_no_sandwich = constant_product_swap(x, y, victim_amount * (1-fee))
    
    # ─── Step 1: Front-run ───
    print(f"\n  ══ Step 1: FRONT-RUN (attacker buys) ══")
    front_dx = front_run_amount * (1 - fee)
    front_dy = constant_product_swap(x, y, front_dx)
    x += front_run_amount
    y -= front_dy
    price_after_front = y / x
    print(f"  Attacker buys {front_dy:.4f} of token Y")
    print(f"  Price impact: {initial_price:.4f} → {price_after_front:.4f} (+{(price_after_front/initial_price-1)*100:.2f}%)")
    
    # ─── Step 2: Victim trade ───
    print(f"\n  ══ Step 2: VICTIM TRADE (worse price!) ══")
    victim_dx = victim_amount * (1 - fee)
    victim_dy = constant_product_swap(x, y, victim_dx)
    x += victim_amount
    y -= victim_dy
    price_after_victim = y / x
    print(f"  Victim receives: {victim_dy:.4f} Y (would have gotten {victim_no_sandwich:.4f})")
    print(f"  Victim loss: {victim_no_sandwich - victim_dy:.4f} Y ({(1-victim_dy/victim_no_sandwich)*100:.2f}%)")
    print(f"  Price: {price_after_front:.4f} → {price_after_victim:.4f}")
    
    # ─── Step 3: Back-run ───
    print(f"\n  ══ Step 3: BACK-RUN (attacker sells) ══")
    # Attacker sells the Y tokens they bought, getting X back
    back_dy = front_dy * (1 - fee)
    back_dx = constant_product_swap(y, x, back_dy)  # Note: reversed!
    
    attacker_profit = back_dx - front_run_amount
    print(f"  Attacker sells {front_dy:.4f} Y → receives {back_dx:.4f} X")
    
    print(f"\n  ┌{'─'*56}┐")
    if attacker_profit > 0:
        print(f"  │{'✨ ATTACKER PROFIT: ' + f'{attacker_profit:.4f} X':^56}│")
    else:
        print(f"  │{'❌ ATTACKER LOSS: ' + f'{attacker_profit:.4f} X':^56}│")
    print(f"  │{'Victim extra cost: ' + f'{victim_no_sandwich - victim_dy:.4f} Y':^56}│")
    print(f"  └{'─'*56}┘")
    
    return attacker_profit, victim_no_sandwich - victim_dy

def visualize_sandwich_profitability():
    """
    Show how sandwich profit varies with front-run size.
    
    Key insight from formal verification:
    - Too small: not enough price impact to profit from
    - Too large: too much slippage on the back-run
    - Optimal: somewhere in between (convex optimization)
    """
    print(f"\n  {'═'*56}")
    print(f"  SANDWICH PROFIT vs FRONT-RUN SIZE")
    print(f"  {'═'*56}")
    
    pool_x, pool_y = 100000, 10000000  # Large pool
    victim_amount = 1000
    
    print(f"\n  Front-run │ Profit  │ Victim Loss │ Visual")
    print(f"  ─────────┼─────────┼─────────────┼" + "─"*25)
    
    best_profit = 0
    best_size = 0
    
    sizes = [10, 50, 100, 200, 500, 1000, 2000, 5000, 10000]
    for size in sizes:
        x, y = pool_x, pool_y
        
        # Front-run
        front_dy = constant_product_swap(x, y, size * 0.997)
        x += size; y -= front_dy
        
        # Victim
        victim_no_sandwich = constant_product_swap(pool_x, pool_y, victim_amount * 0.997)
        victim_dy = constant_product_swap(x, y, victim_amount * 0.997)
        x += victim_amount; y -= victim_dy
        
        # Back-run
        back_dx = constant_product_swap(y, x, front_dy * 0.997)
        
        profit = back_dx - size
        victim_loss = victim_no_sandwich - victim_dy
        
        if profit > best_profit:
            best_profit = profit
            best_size = size
        
        bar_len = max(0, int(profit * 10))
        bar = "█" * min(bar_len, 20) if profit > 0 else "░" * min(abs(int(profit * 10)), 20)
        marker = " ◄── optimal" if size == best_size and profit > 0 else ""
        print(f"  {size:>8}  │ {profit:>+7.2f} │ {victim_loss:>10.4f}  │ {bar}{marker}")
    
    print(f"\n  💡 Optimal front-run ≈ {best_size} X (profit: {best_profit:.2f} X)")

if __name__ == "__main__":
    print("""
╔══════════════════════════════════════════════════════════════════╗
║   🥪  MEV SANDWICH ATTACK SIMULATOR  🥪                        ║
║   Understanding MEV through formal verification                  ║
╚══════════════════════════════════════════════════════════════════╝
    """)
    
    simulate_sandwich(
        pool_x=100000, pool_y=10000000,
        victim_amount=1000,
        front_run_amount=500
    )
    
    visualize_sandwich_profitability()
    
    print(f"\n  📋 FORMAL GUARANTEES (from MEV.lean):")
    print(f"  ✅ Swap output is always positive (sandwich_output_pos)")
    print(f"  ✅ PGA competition drives MEV to zero profit (pga_equilibrium_limit)")
    print(f"  ✅ MEV redistribution improves welfare (mev_redistribution_improves_welfare)")
    print()
