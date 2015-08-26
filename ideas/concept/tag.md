# bewlib - Tag API

## Different tags types

### Spawn Tag

Each workspace (WS) has a spawn tag, where clients that doesn't know where to go, first spawn here.
You can't delete the spawn tag.


### Master Tag

For the tags of a workspace, a tag can be marked as the "Master Tag"

Depreciated :

* when we jump to that workspace, the MasterTag is shown (by default, it's the first one)



### Moment Tag - Just a dialogBox with custom keymap ?

montrer momentanement un tag (un tag avec des truc d'help par exemple)

* quitter ce tag momentané avec {modkey + Esc} ou juste Esc
* remettre le comportement de {modkey + Esc}

type de tag ? System de flags pour qu'un tag ai les caracteristique de plusieurs categories de tag
- moment-tag
- dialog-tag
- help-tag
- config-tag


### Overlay Tag - Panel (a new concept ?) : Useless: use a DialogBox ?

A tag (or a set of things) that is displayed on top of everythings, example:
* A config panel
* A settings panel



## Tag info

In a big dialog box, show every possible infos about the current tag.

- Clients in the tag
- Keymaps stack of the current tag
-
