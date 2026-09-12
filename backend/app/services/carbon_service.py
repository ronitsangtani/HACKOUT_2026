from typing import Tuple, List
from app.models.schemas import AlternativeSuggestion


class CarbonService:
    """
    Carbon calculation factors based on standard IPCC and CEA India emission factors,
    paired with circular alternative recommendations.
    """

    @staticmethod
    def estimate_co2(category: str, activity_type: str, quantity: float, unit: str) -> Tuple[float, str]:
        cat = category.lower().strip()
        act = activity_type.lower().strip()

        # 1. Transport: kg CO2 / km
        if cat == "transport":
            if "car" in act or "petrol" in act:
                factor = 0.18  # ~180 g CO2 / km
            elif "diesel" in act:
                factor = 0.17
            elif "cng" in act:
                factor = 0.14
            elif "bus" in act:
                factor = 0.08
            elif "metro" in act or "train" in act:
                factor = 0.04
            elif "ev" in act or "electric" in act:
                factor = 0.05  # grid-charged indirect
            elif "bicycle" in act or "walking" in act:
                factor = 0.00
            else:
                factor = 0.12
            co2 = quantity * factor
            method = "Distance × Vehicle Emission Factor (IPCC Transport Baseline)"

        # 2. Energy: kg CO2 / kWh or kg LPG
        elif cat == "energy":
            if "electricity" in act or unit.lower() in ("kwh", "units"):
                factor = 0.72  # India grid average ~720 g CO2/kWh
            elif "lpg" in act or "gas" in act:
                factor = 2.98  # ~2.98 kg CO2 / kg LPG
            else:
                factor = 0.65
            co2 = quantity * factor
            method = "Energy Units × Regional Grid Carbon Intensity (CEA Grid Average)"

        # 3. Shopping: kg CO2 per ₹100 or item
        elif cat == "shopping":
            factor = 0.22  # Estimated embodied carbon factor per ₹100
            co2 = (quantity / 100.0) * factor
            method = "Spend × Input-Output Economic Carbon Intensity"

        # 4. Waste: kg CO2e / kg waste
        elif cat == "waste":
            if "plastic" in act:
                factor = 0.35  # Segregated plastic avoided landfill
            elif "organic" in act or "food" in act:
                factor = 0.50  # Methane avoidance potential
            elif "e-waste" in act or "electronic" in act:
                factor = 2.40  # Rare metal recovery offset
            else:
                factor = 0.40
            co2 = quantity * factor
            method = "Segregated Waste Mass × Material Landfill Emission Factor"

        else:
            co2 = quantity * 0.10
            method = "Generic Consumer Factor"

        return round(max(0.00, co2), 2), method

    @staticmethod
    def calculate_points_delta(category: str, activity_type: str, quantity: float, co2_kg: float) -> int:
        cat = category.lower().strip()
        act = activity_type.lower().strip()

        # 1. Transport
        if cat == "transport":
            if "bicycle" in act or "walking" in act or "cycle" in act:
                # Zero emission active mobility
                return 35 + (5 if quantity > 5.0 else 0)
            elif "metro" in act or "train" in act:
                # Clean rapid mass transit
                return 25
            elif "ev" in act or "electric" in act:
                # Electric transit
                return 15
            elif "bus" in act:
                # Shared mass transit
                return 10
            elif "car" in act or "petrol" in act or "diesel" in act:
                # Solo fossil fuel vehicle: High carbon penalty
                penalty = int(15 + (quantity / 2.0))
                return -min(45, penalty)
            else:
                return -10 if co2_kg > 2.0 else 5

        # 2. Energy
        elif cat == "energy":
            if "solar" in act or "renewable" in act:
                # Clean rooftop solar generation
                return 30
            elif "electricity" in act:
                # Conditional grid consumption
                if quantity <= 8.0:
                    return 10  # Conservation reward
                elif quantity <= 15.0:
                    return 0   # Normal baseline (no points, no penalty)
                elif quantity <= 30.0:
                    return -15 # Excessive usage penalty
                else:
                    return -30 # Severe waste penalty
            elif "lpg" in act or "gas" in act:
                # Fossil fuel cylinder
                if quantity <= 1.0:
                    return -10
                else:
                    return -25
            else:
                return -15 if co2_kg > 5.0 else 5

        # 3. Food / Diet
        elif cat in ("food", "diet"):
            if "plant" in act or "vegan" in act or "salad" in act:
                # Sustainable low-carbon meal
                return int(25 * min(quantity, 3.0))
            elif "dairy" in act or "coffee" in act:
                # Moderate footprint
                if quantity <= 2.0:
                    return 5
                else:
                    return -10
            elif "meat" in act or "beef" in act or "chicken" in act or "mutton" in act:
                # High carbon intensity meal
                return -int(20 * min(quantity, 3.0))
            else:
                return -10 if co2_kg > 2.0 else 10

        # 4. Waste
        elif cat == "waste":
            if "compost" in act or "organic" in act:
                # Methane avoidance composting
                return 30
            elif "recycle" in act or "polymer" in act or "segregat" in act:
                # Material recycling circularity
                return 25
            elif "trash" in act or "landfill" in act or "dump" in act:
                # Unsegregated landfill waste
                return -20
            else:
                return 15 if co2_kg < 0.5 else -15

        # 5. Shopping
        elif cat in ("shopping", "goods"):
            if "fashion" in act or "cloth" in act:
                # Fast fashion penalty
                return -int(25 * min(quantity, 3.0))
            elif "electronic" in act or "device" in act or "phone" in act:
                # New electronic device embodied carbon
                return -35
            elif "grocer" in act or "essential" in act or "food" in act:
                if quantity <= 5.0:
                    return 10
                elif quantity <= 10.0:
                    return 0
                else:
                    return -10
            else:
                return -20 if co2_kg > 3.0 else 5

        # 6. Water
        elif cat == "water":
            if "shower" in act:
                if quantity <= 5.0:
                    return 15  # Efficient short shower
                elif quantity <= 10.0:
                    return 0
                else:
                    return -15 # Excessive shower
            else:
                return 10 if quantity <= 50.0 else -15

        # Fallback based on CO2 emitted
        if co2_kg <= 0.5:
            return 20
        elif co2_kg <= 2.0:
            return 5
        else:
            return -int(min(35, co2_kg * 5))

    @classmethod
    def find_alternatives(
        cls, category: str, activity_type: str, quantity: float, unit: str, original_co2: float
    ) -> List[AlternativeSuggestion]:
        cat = category.lower().strip()
        act = activity_type.lower().strip()
        candidates: List[AlternativeSuggestion] = []

        if cat == "transport":
            alt_modes = [
                ("Metro / Rapid Rail", "metro_train", 0.04, "Taking rapid transit reduces per-passenger emissions by ~78% compared to solo driving."),
                ("Public Bus Service", "public_bus", 0.08, "Shared buses drastically cut per-capita urban fuel consumption."),
                ("Electric Vehicle / EV 2-Wheeler", "ev_commute", 0.05, "Electric mobility eliminates direct tailpipe exhaust and cuts urban emissions."),
                ("Bicycle / Active Walking", "bicycle_walk", 0.00, "Zero-emission active travel produces no tailpipe carbon."),
            ]
            for title, alt_type, factor, expl in alt_modes:
                alt_co2 = round(quantity * factor, 2)
                if alt_co2 < original_co2:
                    reduction = round(original_co2 - alt_co2, 2)
                    pct = round((reduction / original_co2) * 100, 1) if original_co2 > 0 else 0.0
                    candidates.append(
                        AlternativeSuggestion(
                            title=title,
                            category="transport",
                            alternativeType=alt_type,
                            estimatedCo2Kg=alt_co2,
                            co2ReductionKg=reduction,
                            percentageReduction=pct,
                            explanation=expl,
                        )
                    )

        elif cat == "energy":
            if "electricity" in act or unit.lower() in ("kwh", "units"):
                solar_co2 = round(quantity * 0.05, 2)
                red_solar = round(original_co2 - solar_co2, 2)
                pct_solar = round((red_solar / original_co2) * 100, 1) if original_co2 > 0 else 0.0
                candidates.append(
                    AlternativeSuggestion(
                        title="Rooftop Solar / Clean Power Offset",
                        category="energy",
                        alternativeType="solar_pv",
                        estimatedCo2Kg=solar_co2,
                        co2ReductionKg=red_solar,
                        percentageReduction=pct_solar,
                        explanation="Solar power avoids coal-dominated grid emissions almost entirely.",
                    )
                )
                eff_co2 = round(original_co2 * 0.70, 2)
                red_eff = round(original_co2 - eff_co2, 2)
                pct_eff = round((red_eff / original_co2) * 100, 1) if original_co2 > 0 else 0.0
                candidates.append(
                    AlternativeSuggestion(
                        title="BEE 5-Star Inverter Appliance Upgrade",
                        category="energy",
                        alternativeType="efficient_appliance",
                        estimatedCo2Kg=eff_co2,
                        co2ReductionKg=red_eff,
                        percentageReduction=pct_eff,
                        explanation="BEE 5-star inverter appliances cut household electricity demand by up to 30%.",
                    )
                )
            elif "lpg" in act or "gas" in act:
                ind_co2 = round(original_co2 * 0.50, 2)
                red_ind = round(original_co2 - ind_co2, 2)
                pct_ind = round((red_ind / original_co2) * 100, 1) if original_co2 > 0 else 0.0
                candidates.append(
                    AlternativeSuggestion(
                        title="Induction Cooktop (Clean Electric)",
                        category="energy",
                        alternativeType="induction_cooking",
                        estimatedCo2Kg=ind_co2,
                        co2ReductionKg=red_ind,
                        percentageReduction=pct_ind,
                        explanation="Induction cooking transfers 85-90% of heat directly to cookware compared to 40% for gas burners.",
                    )
                )

        elif cat == "shopping":
            if "electronic" in act or "gadget" in act:
                refurb_co2 = round(original_co2 * 0.30, 2)
                red_ref = round(original_co2 - refurb_co2, 2)
                candidates.append(
                    AlternativeSuggestion(
                        title="Certified Refurbished & Authorized Repair",
                        category="shopping",
                        alternativeType="refurbished_electronics",
                        estimatedCo2Kg=refurb_co2,
                        co2ReductionKg=red_ref,
                        percentageReduction=70.0,
                        explanation="Extending electronics lifespan prevents energy-intensive silicon fabrication emissions.",
                    )
                )
            elif "cloth" in act or "fashion" in act:
                thrift_co2 = round(original_co2 * 0.20, 2)
                red_th = round(original_co2 - thrift_co2, 2)
                candidates.append(
                    AlternativeSuggestion(
                        title="Thrift, Pre-Owned or Circular Apparel",
                        category="shopping",
                        alternativeType="thrift_fashion",
                        estimatedCo2Kg=thrift_co2,
                        co2ReductionKg=red_th,
                        percentageReduction=80.0,
                        explanation="Buying pre-loved garments saves thousands of liters of virtual water and cotton crop pesticides.",
                    )
                )
            else:
                local_co2 = round(original_co2 * 0.55, 2)
                red_loc = round(original_co2 - local_co2, 2)
                candidates.append(
                    AlternativeSuggestion(
                        title="Local Farm Produce & Minimal Packaging",
                        category="shopping",
                        alternativeType="local_produce",
                        estimatedCo2Kg=local_co2,
                        co2ReductionKg=red_loc,
                        percentageReduction=45.0,
                        explanation="Sourcing unpackaged seasonal regional produce cuts cold-chain logistics emissions.",
                    )
                )

        elif cat == "waste":
            if "plastic" in act:
                rec_co2 = round(original_co2 * 0.25, 2)
                red_rec = round(original_co2 - rec_co2, 2)
                candidates.append(
                    AlternativeSuggestion(
                        title="Verified Drop-Off at Mechanical Recycling Hub",
                        category="waste",
                        alternativeType="plastic_recycling",
                        estimatedCo2Kg=rec_co2,
                        co2ReductionKg=red_rec,
                        percentageReduction=75.0,
                        explanation="Returning polymers to mechanical recycling loops avoids virgin petrochemical resin synthesis.",
                    )
                )
            elif "organic" in act or "food" in act:
                comp_co2 = round(original_co2 * 0.10, 2)
                red_comp = round(original_co2 - comp_co2, 2)
                candidates.append(
                    AlternativeSuggestion(
                        title="Aerobic Home Composting / Community Biogas",
                        category="waste",
                        alternativeType="home_composting",
                        estimatedCo2Kg=comp_co2,
                        co2ReductionKg=red_comp,
                        percentageReduction=90.0,
                        explanation="Aerobic composting stops anaerobic methane breakdown in open landfills.",
                    )
                )
            elif "e-waste" in act or "electronic" in act:
                reclaim_co2 = round(original_co2 * 0.15, 2)
                red_reclaim = round(original_co2 - reclaim_co2, 2)
                candidates.append(
                    AlternativeSuggestion(
                        title="Certified Circular E-Waste Extraction Point",
                        category="waste",
                        alternativeType="ewaste_recovery",
                        estimatedCo2Kg=reclaim_co2,
                        co2ReductionKg=red_reclaim,
                        percentageReduction=85.0,
                        explanation="Recovers critical minerals (copper, lithium, gold) preventing destructive open-cast mining.",
                    )
                )

        # Sort alternatives by maximum CO2 reduction (descending)
        candidates.sort(key=lambda x: x.co2ReductionKg, reverse=True)
        return candidates


carbon_service = CarbonService()
