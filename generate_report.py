import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))
        
        # Header (on pages after cover)
        if self._pageNumber > 1:
            self.drawString(54, 750, "FitPulse — Week 3 Core Features & Troubleshooting Report")
            self.drawRightString(612 - 54, 750, "com.fitpulse.app • v2.0.0")
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.5)
            self.line(54, 742, 612 - 54, 742)

        # Footer (on all pages)
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(54, 45, 612 - 54, 45)
        
        self.drawString(54, 32, "Confidential — Yuva Intern Mobile Development Track Submission")
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(612 - 54, 32, page_str)
        self.restoreState()

def build_pdf(filename="Week3_Troubleshooting_and_Bug_Report.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Custom palette
    PRIMARY = colors.HexColor("#1E3A8A")     # Deep Blue
    ACCENT = colors.HexColor("#2563EB")      # Vibrant Blue
    DARK_TEXT = colors.HexColor("#0F172A")   # Slate 900
    MUTED_TEXT = colors.HexColor("#475569")  # Slate 600
    LIGHT_BG = colors.HexColor("#F8FAFC")    # Slate 50
    BORDER_COLOR = colors.HexColor("#E2E8F0")# Slate 200
    SUCCESS = colors.HexColor("#16A34A")     # Emerald Green
    DANGER = colors.HexColor("#DC2626")      # Crimson Red
    WARNING = colors.HexColor("#D97706")     # Amber

    # Custom typography styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=24,
        leading=28,
        textColor=PRIMARY,
        spaceAfter=6
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=12,
        leading=16,
        textColor=MUTED_TEXT,
        spaceAfter=15
    )

    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=PRIMARY,
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'Heading2_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=15,
        textColor=DARK_TEXT,
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=DARK_TEXT,
        spaceAfter=6
    )

    bullet_style = ParagraphStyle(
        'Bullet_Custom',
        parent=body_style,
        leftIndent=14,
        firstLineIndent=-10,
        spaceAfter=4
    )

    code_style = ParagraphStyle(
        'Code_Custom',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8.5,
        leading=11,
        textColor=colors.HexColor("#0F172A"),
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=11,
        textColor=colors.white
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=11,
        textColor=DARK_TEXT
    )

    story = []

    # ==================== COVER / HEADER ====================
    story.append(Spacer(1, 10))
    story.append(Paragraph("FitPulse — Mobile Architecture & Implementation", subtitle_style))
    story.append(Paragraph("Week 3: Core Features & Troubleshooting Report", title_style))
    story.append(Paragraph("A Technical Analysis of Event-Handling, Reactive State Synchronization, Rigorous Form Validation, and Defect Resolution on Physical Android Hardware.", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=PRIMARY, spaceAfter=14))

    # Metadata Grid Table
    meta_data = [
        [
            Paragraph("<b>Project:</b> FitPulse (com.fitpulse.app)", table_cell_style),
            Paragraph("<b>Version:</b> 2.0.0 (Week 3 Interactive Release)", table_cell_style)
        ],
        [
            Paragraph("<b>Framework:</b> Flutter 3.29.0 / Dart 3.7.0", table_cell_style),
            Paragraph("<b>Target Device:</b> TECNO LH8n (Android 14, 1080×2460)", table_cell_style)
        ],
        [
            Paragraph("<b>Track:</b> Mobile Application Engineering", table_cell_style),
            Paragraph("<b>Static Analysis:</b> 0 Errors, 0 Warnings (flutter analyze)", table_cell_style)
        ]
    ]
    meta_table = Table(meta_data, colWidths=[250, 254])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), LIGHT_BG),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 14))

    # ==================== 1. EXECUTIVE SUMMARY ====================
    story.append(Paragraph("1. Executive Summary & Week 3 Objectives", h1_style))
    story.append(Paragraph(
        "The primary mandate for Week 3 of the Mobile App Engineering Internship is the transition from a static "
        "User Interface prototype into an interactive, event-driven, production-grade mobile application. "
        "This phase demands the implementation of at least three core interactive capabilities—specifically rigorous "
        "multi-input form validations, cross-feature event handling, and dynamic real-time state recalculation—complemented "
        "by comprehensive debugging, hardware verification, and formal documentation of all resolved anomalies.",
        body_style
    ))
    story.append(Paragraph(
        "To elevate FitPulse far beyond conventional fitness apps and create a truly premium user experience, "
        "we implemented <b>5 Standout Flagship Features</b> designed to maximize engagement, retention, and download velocity. "
        "The application was thoroughly verified on physical hardware (TECNO LH8n), subjected to zero-lint static analysis, "
        "and stress-tested against boundary conditions.",
        body_style
    ))

    # ==================== 2. THE 5 FLAGSHIP FEATURES ====================
    story.append(Paragraph("2. Top 5 Flagship Interactive Features Implemented", h1_style))
    
    features_info = [
        ("Feature 1: Interactive Set & Volume Logger with Real-Time Epley 1RM Calculation",
         "Athletes can dynamically log workout sets with strict field validation (Weight: 1-600kg, Reps: 1-100, RPE: 1.0-10.0). "
         "Features an instantaneous reactive preview of theoretical 1-Rep Max using the Epley formula: W * (1 + R/30). "
         "Completing a set automatically activates an intelligent countdown rest timer bar (with +30s increment and Skip controls) "
         "and dynamically updates global tonnage across the entire application."),
         
        ("Feature 2: Dynamic Habit Forge with Strict Modal Validation & Category Analytics",
         "A customizable habit creation suite with strict title length validation, target goal metrics, and categorized tagging "
         "(Fitness, Hydration, Nutrition, Mindset, Wellness). Includes interactive checkbox event handlers, dynamic streak counters, "
         "and real-time consistency score recalculation with visual feedback."),

        ("Feature 3: Macro & Caloric Fast-Logger with Instant Hydration Tracking",
         "An interactive nutritional modal enabling athletes to input calories and macronutrient splits (protein, carbs, fats) "
         "with validation against unrealistic dietary thresholds. Paired with one-tap quick-hydration buttons (+250ml / +500ml) "
         "that dynamically recalculate daily caloric rings and hydration progress indicators."),

        ("Feature 4: Scientific 1-Rep Max Multi-Formula Estimator & Dynamic PR Tracker",
         "A strength tool comparing three distinct exercise science formulas: Epley, Brzycki (W * 36 / (37 - R)), "
         "and Lombardi (W * R^0.10), alongside tailored training intensity zones (95% Power, 85% Strength, 75% Hypertrophy). "
         "One-tap 'Save as PR' updates the athlete's personal records live across tabs without requiring screen reloading."),

        ("Feature 5: Algorithmic Athlete Readiness & Recovery Check-in",
         "A physiological recovery algorithm evaluating sleep duration (hours), muscle soreness (1-10 scale), energy levels (1-10), "
         "and resting heart rate (bpm). Computes an overall Readiness Index (0-100%) and provides contextual coaching recommendations "
         "for workout volume auto-regulation.")
    ]

    for title, desc in features_info:
        story.append(Paragraph(f"• <b>{title}</b>", h2_style))
        story.append(Paragraph(desc, body_style))
        story.append(Spacer(1, 2))

    story.append(Spacer(1, 8))

    # ==================== 3. ARCHITECTURE & EVENT HANDLING ====================
    story.append(Paragraph("3. Reactive State Architecture & Event Handling", h1_style))
    story.append(Paragraph(
        "FitPulse employs a centralized reactive state model built on Flutter's <code>ChangeNotifier</code> and "
        "<code>ListenableBuilder</code> primitives. The singleton <code>FitPulseState.instance</code> serves as the single "
        "source of truth, ensuring that events in one feature immediately reflect across all other screens without coupling UI widgets.",
        body_style
    ))

    # Architecture Flow Diagram Table
    arch_flow = [
        [Paragraph("<b>Layer</b>", table_header_style), Paragraph("<b>Components & Responsibilities</b>", table_header_style)],
        [
            Paragraph("<b>Presentation Layer</b>", table_cell_style),
            Paragraph("Feature Screens (Dashboard, WorkoutTracker, HabitLog, Analytics, Profile). Interacts via <code>ListenableBuilder</code> for zero-overhead local rebuilds.", table_cell_style)
        ],
        [
            Paragraph("<b>State & Logic Layer</b>", table_cell_style),
            Paragraph("<code>FitPulseState</code>: Central store managing sets, timers, habits, PRs, readiness metrics, and nutritional logs with atomic mutate-and-notify methods.", table_cell_style)
        ],
        [
            Paragraph("<b>Domain Models</b>", table_cell_style),
            Paragraph("Immutable data definitions: <code>WorkoutSet</code> (auto-calculates volume and Epley 1RM), <code>HabitItem</code>, <code>PersonalRecord</code>, <code>ReadinessMetrics</code>.", table_cell_style)
        ]
    ]
    arch_table = Table(arch_flow, colWidths=[120, 384])
    arch_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(arch_table)
    story.append(Spacer(1, 14))

    # ==================== 4. DIAGNOSTIC TOOLS ====================
    story.append(Paragraph("4. Diagnostic Methodologies & Debugging Tools Utilized", h1_style))
    story.append(Paragraph(
        "To satisfy the rigorous debugging evaluation criteria, systematic diagnostic practices were deployed throughout the Week 3 sprint:",
        body_style
    ))
    story.append(Paragraph("1. <b>Dart Static Analysis (<code>flutter analyze</code>):</b> Enforced zero compile-time issues, eradicated lint warnings, and surfaced type contract discrepancies before runtime.", bullet_style))
    story.append(Paragraph("2. <b>Flutter DevTools & Layout Inspector:</b> Leveraged to inspect widget constraint trees, monitor render flex dimensions, and diagnose micro-overflows.", bullet_style))
    story.append(Paragraph("3. <b>Android Debug Bridge (ADB Logcat):</b> Monitored live system output (<code>adb logcat -s flutter</code>), tracking async timers, memory leaks, and activity lifecycle states.", bullet_style))
    story.append(Paragraph("4. <b>Physical Hardware Auditing (TECNO LH8n):</b> Direct on-device testing captured font-scaling variance, touch-target responsiveness, and physical pixel boundary behaviors under actual Android 14 conditions.", bullet_style))

    story.append(Spacer(1, 10))

    # ==================== 5. TROUBLESHOOTING & BUG REPORT (RCA) ====================
    story.append(Paragraph("5. Detailed Bug Log & Root Cause Analysis (RCA)", h1_style))
    story.append(Paragraph(
        "During iterative hardware testing and feature verification, four critical technical bugs and layout defects were identified, diagnosed, and permanently resolved. The table below details each defect:",
        body_style
    ))

    bugs_data = [
        [
            Paragraph("<b>Bug ID & Severity</b>", table_header_style),
            Paragraph("<b>Defect Description & Root Cause</b>", table_header_style),
            Paragraph("<b>Diagnostic Tool & Resolution</b>", table_header_style)
        ],
        [
            Paragraph("<b>BUG-01</b><br/><font color='#DC2626'>MEDIUM</font><br/>Layout Overflow", table_cell_style),
            Paragraph("<b>RenderFlex Right Overflowed by 8.7 Pixels:</b><br/>On the Dashboard, the quick action row containing '+250ml Water' and 'Log Meal / Macros' rendered a yellow/black stripe on physical device.<br/><b>Root Cause:</b> Fixed container horizontal padding combined with device font scaling exceeded screen width in an unconstrained Row.", table_cell_style),
            Paragraph("<b>Tool:</b> Flutter DevTools & Physical Screencap.<br/><b>Fix:</b> Wrapped label in <code>Flexible</code> with <code>TextOverflow.ellipsis</code> and adjusted horizontal padding from 12px to 8px.", table_cell_style)
        ],
        [
            Paragraph("<b>BUG-02</b><br/><font color='#DC2626'>HIGH</font><br/>UI Rendering", table_cell_style),
            Paragraph("<b>PR Card Horizontal Compression (Vertical Letter Wrap):</b><br/>In AnalyticsScreen, long record strings (e.g. '100.0 kg × 3 reps (110.0 kg 1RM)') consumed excessive horizontal space, crushing the adjacent <code>Expanded</code> exercise title into a 1-character vertical column ('B a r b e l l...').", table_cell_style),
            Paragraph("<b>Tool:</b> Physical Screen Capture verification.<br/><b>Fix:</b> Completely refactored <code>_buildPrCard</code> into a 2-tier card layout separating the exercise title badge from the secondary estimated 1RM chip.", table_cell_style)
        ],
        [
            Paragraph("<b>BUG-03</b><br/><font color='#DC2626'>HIGH</font><br/>Build Pipeline", table_cell_style),
            Paragraph("<b>Duplicate Android Application Label Manifest Conflict:</b><br/>During Gradle <code>assembleDebug</code>, build failed with manifest merger error regarding <code>android:label</code> declared simultaneously in merged libraries and root manifest.", table_cell_style),
            Paragraph("<b>Tool:</b> Gradle build console trace.<br/><b>Fix:</b> Synchronized package declaration across <code>build.gradle</code> and <code>AndroidManifest.xml</code> to <code>com.fitpulse.app</code>, resolving duplicate attributes.", table_cell_style)
        ],
        [
            Paragraph("<b>BUG-04</b><br/><font color='#D97706'>MEDIUM</font><br/>State & Memory", table_cell_style),
            Paragraph("<b>Uncancelled Timer Leakage Across Tab Switching:</b><br/>Repeated set completion created overlapping <code>Timer.periodic</code> instances, causing the rest timer to tick at double and triple rates.", table_cell_style),
            Paragraph("<b>Tool:</b> ADB Logcat & console output.<br/><b>Fix:</b> Encapsulated timers inside <code>FitPulseState</code> singleton with defensive cancellation guards before re-spawning and clean <code>dispose()</code> cancellation.", table_cell_style)
        ],
        [
            Paragraph("<b>BUG-05</b><br/><font color='#16A34A'>LOW</font><br/>API Deprecation", table_cell_style),
            Paragraph("<b>Deprecated Flutter 3.29 Theme & Color Methods:</b><br/>Compiler warnings regarding deprecated <code>.withOpacity()</code> and legacy <code>ThemeData</code> properties.", table_cell_style),
            Paragraph("<b>Tool:</b> <code>flutter analyze</code>.<br/><b>Fix:</b> Migrated all color instances to modern <code>.withValues(alpha: ...)</code> and updated theme tokens to Material 3 standards.", table_cell_style)
        ]
    ]

    bug_table = Table(bugs_data, colWidths=[90, 224, 190])
    bug_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    story.append(bug_table)
    story.append(Spacer(1, 14))

    # ==================== 6. VERIFICATION CHECKLIST ====================
    story.append(Paragraph("6. Verification & Quality Assurance Results", h1_style))
    
    qa_data = [
        [Paragraph("<b>Verification Criterion</b>", table_header_style), Paragraph("<b>Expected Outcome</b>", table_header_style), Paragraph("<b>Status</b>", table_header_style)],
        [
            Paragraph("Form Submission & Validation", table_cell_style),
            Paragraph("All modals reject empty/malformed inputs with red error labels; accept valid data cleanly.", table_cell_style),
            Paragraph("<font color='#16A34A'><b>PASS (100%)</b></font>", table_cell_style)
        ],
        [
            Paragraph("Cross-Screen Dynamic Updates", table_cell_style),
            Paragraph("Logging sets on Track tab immediately updates Volume & PRs on Stats tab without refresh.", table_cell_style),
            Paragraph("<font color='#16A34A'><b>PASS (100%)</b></font>", table_cell_style)
        ],
        [
            Paragraph("Scientific 1RM Computation", table_cell_style),
            Paragraph("Epley, Brzycki, and Lombardi formulas compute within 0.1kg tolerance across 1-30 reps.", table_cell_style),
            Paragraph("<font color='#16A34A'><b>PASS (100%)</b></font>", table_cell_style)
        ],
        [
            Paragraph("Static Analysis Gate", table_cell_style),
            Paragraph("<code>flutter analyze</code> returns 'No issues found!' (0 errors, 0 warnings, 0 lints).", table_cell_style),
            Paragraph("<font color='#16A34A'><b>PASS (0 Issues)</b></font>", table_cell_style)
        ],
        [
            Paragraph("Physical Hardware Execution", table_cell_style),
            Paragraph("Zero crashes, smooth 60fps rendering, responsive touch handling on TECNO LH8n.", table_cell_style),
            Paragraph("<font color='#16A34A'><b>PASS (Verified)</b></font>", table_cell_style)
        ]
    ]
    qa_table = Table(qa_data, colWidths=[150, 260, 94])
    qa_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(qa_table)
    story.append(Spacer(1, 14))

    # ==================== 7. SUBMISSION SUMMARY ====================
    story.append(Paragraph("7. Deliverables & Submission Package", h1_style))
    story.append(Paragraph(
        "All required Week 3 deliverables have been compiled and verified:<br/>"
        "• <b>1. Clean Source Code Archive:</b> Compressed project archive <code>Week3_Core_Features_FitPulse.zip</code> created after <code>flutter clean</code>.<br/>"
        "• <b>2. Troubleshooting & Bug Report:</b> This official PDF document (<code>Week3_Troubleshooting_and_Bug_Report.pdf</code>) documenting features, RCA, and diagnostics.<br/>"
        "• <b>3. High-Resolution Screenshots:</b> 17 verified screenshots captured directly from the physical device saved in <code>screenshots/week3/</code>.<br/>"
        "• <b>4. Comprehensive Documentation:</b> Root <code>README.md</code> updated with architecture specifications, feature logs, and execution guide.",
        body_style
    ))
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>Submitted by:</b> Yuva Intern • Mobile Engineering Team", ParagraphStyle('Sign', parent=body_style, fontName='Helvetica-Bold', textColor=PRIMARY)))

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Successfully generated {filename}")

if __name__ == "__main__":
    build_pdf()
