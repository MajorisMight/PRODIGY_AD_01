String classifyQRContent(String text) {
  final uri = Uri.tryParse(text);
  if (uri == null) return 'invalid';

  if (uri.scheme == 'http' || uri.scheme == 'https') return 'web_link';
  if (uri.scheme == 'upi') return 'upi_payment';
  if (uri.scheme == 'mailto') return 'email';
  if (uri.scheme == 'tel') return 'phone';
  if (uri.scheme == 'geo') return 'map_location';
  if (uri.scheme == 'sms') return 'sms_link';
  if (uri.scheme != '' && uri.scheme != 'http') return 'app_deep_link';

  if (text.startsWith('WIFI:')) return 'wifi_credentials';
  if (text.startsWith('BEGIN:VCARD') || text.startsWith('MECARD:')) return 'contact_card';
  if (text.startsWith('BEGIN:VEVENT')) return 'calendar_event';
  if (text.trim().startsWith('{') && text.trim().endsWith('}')) return 'json_data';
  if (RegExp(r'^[A-Z0-9]{6,}$').hasMatch(text)) return 'token_or_coupon';
  if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(text)) return 'base64_or_encrypted';
  
  return 'plain_text';
}
