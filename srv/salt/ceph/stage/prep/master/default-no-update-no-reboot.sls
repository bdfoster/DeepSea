salt-api:
  salt.state:
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - sls: ceph.salt-api

{% if salt['saltutil.runner']('validate.setup') == False %}

validate failed:
  salt.state:
    - name: just.exit
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - failhard: True

{% endif %}

{% if salt['saltutil.runner']('validate.saltapi') == False %}

salt-api failed:
  salt.state:
    - name: just.exit
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - failhard: True

{% endif %}

sync master:
  salt.state:
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - sls: ceph.sync

{% set notice = salt['saltutil.runner']('advise.salt_run') %}

repo master:
  salt.state:
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - sls: ceph.repo

{% set kernel= grains['kernelrelease'] | replace('-default', '')  %}

unlock:
  salt.runner:
    - name: filequeue.remove
    - queue: 'master'
    - item: 'lock'
    - unless: "rpm -q --last kernel-default | head -1 | grep -q {{ kernel }}"

complete marker:
  salt.runner:
    - name: filequeue.add
    - queue: 'master'
    - item: 'complete'

ready:
  salt.runner:
    - name: minions.ready
    - timeout: {{ salt['pillar.get']('ready_timeout', 300) }}




