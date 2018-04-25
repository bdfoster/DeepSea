
create_mon_dirs:
  file.directory:
    - names:
        - /var/lib/ceph/mon/
        - /var/lib/ceph/tmp/
    - user: ceph
    - group: ceph
    - makedirs: true
    - recurse:
        - user
        - group

/var/lib/ceph/tmp/keyring.mon:
  file.managed:
    - source: 
      - salt://ceph/mon/cache/mon.keyring
    - user: ceph
    - group: ceph
    - mode: 600
    - makedirs: True
    - fire_event: True


{% set cluster = salt['pillar.get']('cluster') %}
{% set fsid = salt['pillar.get']('fsid') %}

create_mon_fs:
  cmd.run:
    - name: ceph-mon --mkfs -i {{ grains['host'] }} --cluster {{ cluster }} --setuser ceph --setgroup ceph --fsid  {{ fsid }} --keyring /var/lib/ceph/tmp/keyring.mon
    - creates: /var/lib/ceph/mon/{{ cluster }}-{{ grains['host'] }}/keyring
    - require:
        - file: /var/lib/ceph/tmp/keyring.mon


start mon:
  service.running:
    - name: ceph-mon@{{ grains['host'] }}
    - require:
      - cmd: create_mon_fs
    - enable: True


wait for mon:
  module.run:
    - name: cephprocesses.wait
    - kwargs:
        'timeout': 6
        'delay': 2
        'roles':
          - mon
    - fire_event: True
    - failhard: True
