import osmnx as ox
import folium
import networkx as nx
import matplotlib.pyplot as plt
import pandas as pd

#G = ox.graph_from_place("Bari, Italy", network_type="drive", simplify=True)

#Salvare la rete in formato GraphML
#ox.save_graphml(G, "rete_bari.graphml")

#Caricare la rete da file GraphML
G = ox.load_graphml("rete_bari_incidenti.graphml")

#Disegnare il grafo statico
#fig, ax = ox.plot_graph(G, node_size=5, edge_linewidth=0.7, bgcolor="white")
#plt.show()

edge = list(G.edges(data=True))[0]  # Prendere il primo arco
print(edge)  # Mostrare le informazioni

# AGGIUNTA NUMERI INCIDENTI GRAFO

# df = pd.read_csv(".\\Dati\\Dati_aggregati.csv")

# incidenti_dict = df.groupby("ID_Segmento")["NUM_INCIDENTI"].sum().to_dict()

# for u, v, k, data in G.edges(data=True, keys=True):
#     if "osmid" in data:
#         osmids = data["osmid"]

#         if isinstance(osmids, list):
#             incidenti_count = sum(incidenti_dict.get(osmid, 0) for osmid in osmids)
#         else:
#             incidenti_count = incidenti_dict.get(osmids, 0)

#         data["incidenti"] = incidenti_count

# ox.save_graphml(G, "rete_bari_incidenti.graphml")
# print("Grafo salvato con successo")
