.PHONY: patches

export GIT_COMMITTER_DATE = Wed, 31 Jul 2019 12:00:00 -0500
export GIT_AUTHOR_DATE = Wed, 31 Jul 2019 12:00:00 -0500

patches: pandas
	git -C pandas apply ../docs.patch
	git -C pandas add doc/source/conf.py         && git -C pandas commit -m 'PATCH: update conf.py'
	find pandas/doc/source/getting_started -name '*.rst' -exec sed -i -e 's/.. ipython:: python/.. code:: python/g' '{}' \;
	find pandas/doc/source/getting_started -name '*.rst' -exec sed -i -e 's/ *@savefig .*//g' '{}' \;
	git -C pandas add doc/source/getting_started && git -C pandas commit -m 'PATCH: update getting-started'
	rm -rf pandas/doc/source/reference
	git -C pandas add doc/source/reference       && git -C pandas commit -m 'PATCH: remove API reference'
	git -C pandas format-patch HEAD~3 -o ../patches
	git -C pandas reset --hard HEAD~3

patch: pandas patches
	# TODO: This leaves the pandas submodule in a dirty state. But we don't actually want to
	# apply the changes, since the applied commits won't exist anywhere.
	cd pandas && git apply ../patches/*.patch

jupyter:
	sphinx-build -b jupyter -d pandas/doc/build/doctrees -j 8 pandas/doc/source/ build/jupyter
