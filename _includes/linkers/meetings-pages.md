{% capture /dev/null %}
{% if page.url == "/meetings/" %}
  {% assign _index_links = _index_links | append: "<span style='font-weight: bold'>By date</span>" %}
{% else %}
  {% assign _index_links = _index_links | append: "<a href='/meetings/'>By date</a>" %}
{% endif %}
{% if page.url == "/en/meetings-components/" %}
  {% assign _index_links = _index_links | append: " | <span style='font-weight: bold'>Components</span>" %}
{% else %}
  {% assign _index_links = _index_links | append: " | <a href='/meetings-components/'>Components</a>" %}
{% endif %}
{% if page.url == "/en/meetings-hosts/" %}
  {% assign _index_links = _index_links | append: " | <span style='font-weight: bold'>Hosts</span>" %}
{% else %}
  {% assign _index_links = _index_links | append: " | <a href='/meetings-hosts/'>Hosts</a>" %}
{% endif %}
{% endcapture %}
| {{_index_links}} |
