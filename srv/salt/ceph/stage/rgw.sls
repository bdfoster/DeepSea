
#rgw pools:
#  salt.state:
#    - tgt: "{{ salt.saltutil.runner('select.one_minion', cluster='ceph', roles='rgw') }}"
#    - sls: ceph.rgw.pools

rgw auth:
  salt.state:
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - tgt_type: compound
    - sls: ceph.rgw.auth

rgw:
  salt.state:
    - tgt: "I@roles:rgw and I@cluster:ceph"
    - tgt_type: compound
    - sls: ceph.rgw
    - require:
        - salt: rgw auth
