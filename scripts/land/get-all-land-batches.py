#!/usr/bin/env python

from glamod.prepare.land_batcher import LandBatcher


batcher = LandBatcher()
batches = batcher.get_batches()


for batch_id in batches:
    print(batch_id)
