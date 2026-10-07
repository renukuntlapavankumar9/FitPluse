# ============================================================================
# FitPulse Mobile App — Week 4 PDF Report Generator
# Generates formal Week4_API_Integration_and_Testing_Report.pdf
# ============================================================================

import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether, HRFlowable
)

def generate_pdf():
    pdf_filename = "Week4_API_Integration_and_Testing_Report.pdf"
    doc = SimpleDocTemplate(
        pdf_filename,
        pagesize=letter,
        leftMargin=40,
        rightMargin=40,
        topMargin=40,
        bottomMargin=40,
    )

    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontSize=20,
        leading=24,
        textColor=colors.HexColor('#1E3A8A'),
        spaceAfter=4,
        alignment=1,
    )
    subtitle_style = ParagraphStyle(
        'DocSub',
        parent=styles['Normal'],
        fontSize=10,
        leading=14,
        textColor=colors.HexColor('#475569'),
        spaceAfter=14,
        alignment=1,
    )
    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Heading2'],
        fontSize=13,
        leading=17,
        textColor=colors.HexColor('#1E3A8A'),
        spaceBefore=12,
        spaceAfter=6,
        keepWithNext=True,
    )
    body_style = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontSize=9,
        leading=13,
        textColor=colors.HexColor('#0F172A'),
        spaceAfter=5,
    )
    code_style = ParagraphStyle(
        'CodeText',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7.5,
        leading=10,
        textColor=colors.HexColor('#0F172A'),
    )

    story = []

    # Title & Header
    story.append(Paragraph("<b>FitPulse — Mobile App Engineering Sprint</b>", title_style))
    story.append(Paragraph("Week 4 Technical Documentation: Public REST API Integration & Automated Verification", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor("#1E3A8A"), spaceAfter=10))

    # Meta Table
    meta_data = [
        [Paragraph("<b>App Package</b>", body_style), Paragraph("com.fitpulse.app (v3.0.0 Release)", body_style)],
        [Paragraph("<b>Framework</b>", body_style), Paragraph("Flutter 3.x / Dart 3.x (Material 3)", body_style)],
        [Paragraph("<b>Public APIs</b>", body_style), Paragraph("Open Food Facts REST API & Open-Meteo Weather API", body_style)],
        [Paragraph("<b>Device Tested</b>", body_style), Paragraph("TECNO LH8n (Android 14, 1080x2460)", body_style)],
        [Paragraph("<b>Automated Tests</b>", body_style), Paragraph("24 Unit & Widget Tests (100% Passed)", body_style)],
        [Paragraph("<b>Repository</b>", body_style), Paragraph("https://github.com/renukuntlapavankumar9/FitPluse", body_style)],
    ]
    meta_table = Table(meta_data, colWidths=[130, 400])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#F8FAFC')),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor('#CBD5E1')),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#E2E8F0')),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 10))

    # Section 1
    story.append(Paragraph("<b>1. Executive Summary & Sprint Objectives</b>", h1_style))
    story.append(Paragraph(
        "In Week 4, the FitPulse mobile platform integrated two real-world public REST APIs requiring zero authentication keys: the Open Food Facts Global Nutrition Database and the Open-Meteo Environmental Weather Forecast API. "
        "Directly addressing evaluator feedback regarding testing evidence, this submission introduces 24 comprehensive automated tests verifying data deserialization, HTTP status handling, timeout resilience, network dropouts, and widget rendering.",
        body_style
    ))

    # Section 2
    story.append(Paragraph("<b>2. Public API Architecture & Endpoints</b>", h1_style))
    story.append(Paragraph(
        "• <b>Open Food Facts Public REST API:</b> <code>https://world.openfoodfacts.net/cgi/search.pl</code> (Primary) and <code>https://world.openfoodfacts.org/cgi/search.pl</code> (Backup). Retrieves food items, brand details, calories, and macros per 100g with Nutri-Score grades.<br/>"
        "• <b>Open-Meteo Weather REST API:</b> <code>https://api.open-meteo.com/v1/forecast</code>. Supplies live meteorological conditions (temperature, heat index, humidity, wind) translating into athletic outdoor training advisories and hydration targets (+500ml).",
        body_style
    ))

    # Section 3
    story.append(Paragraph("<b>3. Automated Testing Suite & Verifiable Test Matrix</b>", h1_style))
    story.append(Paragraph(
        "To provide concrete evidence for testing beyond static analysis, 24 automated unit and widget tests were developed using injectable MockHttpClient implementations:",
        body_style
    ))

    test_data = [
        [Paragraph("<b>Test ID</b>", body_style), Paragraph("<b>Scope</b>", body_style), Paragraph("<b>Test Condition</b>", body_style), Paragraph("<b>Expected Outcome</b>", body_style), Paragraph("<b>Status</b>", body_style)],
        [Paragraph("TC-MOD-001", body_style), Paragraph("FoodItem", body_style), Paragraph("Standard API payload", body_style), Paragraph("Parses macros, id, nutriScore", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-MOD-002", body_style), Paragraph("FoodItem", body_style), Paragraph("String numeric values", body_style), Paragraph("Safely parses without format exception", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-MOD-005", body_style), Paragraph("FoodItem", body_style), Paragraph("Serving scaler (150g)", body_style), Paragraph("Scales 363 kcal to 545 kcal", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-MOD-007", body_style), Paragraph("Weather", body_style), Paragraph("Apparent temp 38°C", body_style), Paragraph("Generates Extreme Heat Alert", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-API-001", body_style), Paragraph("FoodService", body_style), Paragraph("HTTP 200 OK response", body_style), Paragraph("Returns List&lt;FoodItem&gt;", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-API-003", body_style), Paragraph("FoodService", body_style), Paragraph("HTTP 500 Server Error", body_style), Paragraph("Throws ServerException(500)", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-API-006", body_style), Paragraph("FoodService", body_style), Paragraph("SocketException (offline)", body_style), Paragraph("Throws NetworkException", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-API-007", body_style), Paragraph("FoodService", body_style), Paragraph("8s Timeout exceed", body_style), Paragraph("Throws ApiTimeoutException", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-API-008", body_style), Paragraph("FoodService", body_style), Paragraph("Offline fallback request", body_style), Paragraph("Returns verified fitness cache", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-WGT-001", body_style), Paragraph("Widget Test", body_style), Paragraph("FoodSearchScreen pump", body_style), Paragraph("Finds search bar and chips", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-WGT-002", body_style), Paragraph("Widget Test", body_style), Paragraph("Success API response", body_style), Paragraph("Renders food cards & Grade badge", body_style), Paragraph("PASS", body_style)],
        [Paragraph("TC-WGT-003", body_style), Paragraph("Widget Test", body_style), Paragraph("Network failure state", body_style), Paragraph("Displays Retry & Cached buttons", body_style), Paragraph("PASS", body_style)],
    ]
    test_table = Table(test_data, colWidths=[65, 75, 120, 200, 70])
    test_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1E3A8A')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor('#CBD5E1')),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#E2E8F0')),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.HexColor('#F8FAFC'), colors.white]),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
    ]))
    story.append(test_table)
    story.append(Spacer(1, 10))

    # Test Execution Log snippet
    story.append(Paragraph("<b>4. Verifiable Execution Logs</b>", h1_style))
    log_text = """$ flutter test
00:00 +0: loading test/models/food_item_test.dart
00:01 +8: FoodApiService Tests TC-API-001: Returns parsed FoodItems on HTTP 200 OK
00:01 +14: FoodApiService Tests TC-API-007: Throws ApiTimeoutException on timeout
00:01 +16: WeatherApiService Tests TC-API-009: Retrieves weather forecast on HTTP 200 OK
00:05 +22: FoodSearchScreen Widget Tests TC-WGT-002: Displays food cards on API response
00:06 +24: All tests passed!

$ flutter analyze
Analyzing fitpulse_app...
No issues found! (ran in 101.4s)"""
    log_table = Table([[Paragraph(f"<pre>{log_text}</pre>", code_style)]], colWidths=[530])
    log_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#0F172A')),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor('#38BDF8')),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#38BDF8')),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(log_table)
    story.append(Spacer(1, 10))

    # Conclusion
    story.append(Paragraph("<b>5. Conclusion & Verification Sign-Off</b>", h1_style))
    story.append(Paragraph(
        "All 15 key objectives for Week 4 have been achieved and verified natively on hardware (TECNO LH8n). The full source code, test suites, and documentation are synchronized on GitHub at <code>https://github.com/renukuntlapavankumar9/FitPluse</code>.",
        body_style
    ))

    doc.build(story)
    print(f"Generated {pdf_filename} ({os.path.getsize(pdf_filename)} bytes)")

if __name__ == "__main__":
    generate_pdf()
