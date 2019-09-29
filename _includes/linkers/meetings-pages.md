{% capture /dev/null %}
{% assign path = page.path | remove: ".html" %}
{% if path == "meetings" %}
  {% assign _index_links = _index_links | append: "<strong>By date</strong>" %}
{% else %}
  {% assign _index_links = _index_links | append: "<a href='/meetings/'>By date</a>" %}
{% endif %}
{% if path == "meetings-components" %}
  {% assign _index_links = _index_links | append: " | <strong>Components</strong>" %}
{% else %}
  {% assign _index_links = _index_links | append: " | <a href='/meetings-components/'>Components</a>" %}
{% endif %}
{% if path == "meetings-hosts" %}
  {% assign _index_links = _index_links | append: " | <strong>Hosts</strong>" %}
{% else %}
  {% assign _index_links = _index_links | append: " | <a href='/meetings-hosts/'>Hosts</a>" %}
{% endif %}
{% endcapture %}
| {{_index_links}} |
