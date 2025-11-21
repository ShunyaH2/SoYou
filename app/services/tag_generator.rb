require "json"

class TagGenerator
  def initialize(post)
    @post = post
    @client = GeminiClient.new
  end

  # 公開メソッド：タグを生成して post に紐づける
  def assign_tags!
    if @post.body.strip.size < 30
      Rails.logger.info "[TagGenerator] Skipped: too short body"
      @post.tags = []
      return
    end

    tag_names = generate_tag_names_from_ai
    return if tag_names.empty?

    tags = Tag.where(name: tag_names, active: true)
    @post.tags = tags  # 既存タグを置き換える想定。追加したいなら << に変更
  rescue => e
    Rails.logger.error "[TagGenerator] Failed: #{e.class} #{e.message}"
  end

  private

  def generate_tag_names_from_ai
    master_names = Tag.where(active: true).order(:id).pluck(:name)

    prompt = build_prompt(@post.body, master_names)
    raw = @client.generate_text(prompt)

    json_text = extract_json(raw)
    data = JSON.parse(json_text) rescue {}

    ai_tags = Array(data["tags"]).map(&:to_s)

    # マスタに存在するものだけに絞る & 重複排除
    ai_tags.uniq & master_names
  rescue JSON::ParserError => e
    Rails.logger.error "[TagGenerator] JSON parse error: #{e.message}"
    []
  end

  def build_prompt(body, master_names)
    <<~PROMPT
      あなたは家族向けアプリ「SoYou」の性格タグ付けAIです。

      以下のエピソード文を読み、「性格の特徴」が分かるタグを選んでください。

      ▼「タグなし（判断できない）」とすべき条件
      - 文章が短すぎる（例：30文字未満）
      - 具体的な行動や性格が分からない
      - 単語のみ、意味がふめいな内容、事務連絡だけの文章

      【タグマスタ一覧】
      以下のリストに含まれるタグの中から、最大3個だけ選んでください。
      ここにない言葉は使わないでください。

      #{master_names.join(" / ")}

      【出力形式】
      JSONだけを返してください。説明文や文章は書かないでください。

      形式：
      {
        "tags": ["タグ1", "タグ2", ...]
      }

      【制約】
      - タグは必ずタグマスタ一覧の中から選ぶこと
      - 同じ意味の言い換え（例：積極的／積極性／前向き）は避け、
        タグマスタ一覧の表現そのものを使うこと
      - "tags" の配列以外のキーは含めない

      【エピソード】
      #{body}
    PROMPT
  end

  # LLM が前後に文章を付けてきた場合に備えて、
  # 最初の { から最後の } までを抜き出す簡易ヘルパー
  def extract_json(raw)
    return raw if raw.strip.start_with?("{")

    start_index = raw.index("{")
    end_index   = raw.rindex("}")

    if start_index && end_index && end_index > start_index
      raw[start_index..end_index]
    else
      raw # ダメ元でそのまま返す
    end
  end
end